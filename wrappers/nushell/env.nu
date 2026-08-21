$env.config.show_banner = false
$env.TERM = "ghostty"
$env.TERMINAL = "ghostty"
$env.config.buffer_editor = "nvim"
$env.VISUAL = "nvim"
$env.EDITOR = "nvim"

$env.config.hooks.env_change.PWD = [
{ ||
    if (which direnv | is-empty) {
        return
    }

    direnv export json | from json | default {} | load-env
}
]
