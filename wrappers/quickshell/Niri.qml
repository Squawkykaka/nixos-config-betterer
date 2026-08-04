pragma Singleton

import Quickshell
import Quickshell.Io
import QtQuick

Scope {
    id: root

    property list<var> workspaces: []
    property list<var> windows: []
    property var focused_window: null
    property bool overview_open: false

    onWindowsChanged: {
        console.log(JSON.stringify(windows));
    }

    Process {
        id: niriIpc
        running: true
        command: ["niri", "msg", "--json", "event-stream"]

        function handleIpc(message) {
            let json;
            try {
                json = JSON.parse(message);
            } catch (e) {
                console.warn(e);
                return;
            }
            let event = Object.entries(json)[0];
            let eventType = event[0];
            let eventContents = event[1];

            switch (eventType) {
            case "WorkspacesChanged":
                root.workspaces = eventContents.workspaces;
                break;
            case "WorkspaceActivated":
                let activeWorkspaceIndex = root.workspaces.findIndex(el => el.id == eventContents.workspace_id);
                root.workspaces[activeWorkspaceIndex].is_focused = eventContents.focused;
                break;
            case "WorkspaceActiveWindowChanged":
                let workspaceIndex = root.workspaces.findIndex(el => el.id == eventContents.workspace_id);
                root.workspaces[workspaceIndex].active_window_id = eventContents.active_window_id;
                break;
            case "WindowFocusChanged":
                root.focused_window = eventContents.id;
                break;
            case "WindowsChanged":
                root.windows = eventContents.windows;
                break;
            case "WindowClosed":
                let windowIndex = root.windows.findIndex(el => el.id == eventContents.id);
                root.windows.splice(windowIndex, 1);
                break;
            case "WindowOpenedOrChanged":
                let newWindowIndex = root.windows.findIndex(el => el.id == eventContents.window.id);
                if (newWindowIndex == -1) {
                    // this is a new window
                    root.windows.push(eventContents.window);
                } else {
                    root.windows[newWindowIndex] = eventContents.window;
                }
                break;
            case "WindowFocusTimestampChanged":
                const index = root.windows.findIndex(w => w.id === eventContents.id);
                if (index !== -1) {
                    root.windows[index].focus_timestamp = eventContents.focus_timestamp;
                }
                break;
            case "OverviewOpenedOrClosed":
                root.overview_open = eventContents.is_open;
                break;
            default:
                break;
            }
        }

        stdout: StdioCollector {
            property int processedLines: 0

            waitForEnd: false
            onTextChanged: {
                const lines = text.split("\n");
                while (processedLines < lines.length - 1) {
                    const line = lines[processedLines++];

                    if (line.length > 0)
                        niriIpc.handleIpc(line);
                }
            }
        }
    }
}
