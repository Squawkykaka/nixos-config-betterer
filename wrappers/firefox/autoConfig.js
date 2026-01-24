lockPref("sidebar.verticalTabs", true);
lockPref("sidebar.main.tools", "");

try {
  let sss = Components.classes["@mozilla.org/content/style-sheet-service;1"].getService(Components.interfaces.nsIStyleSheetService);
  let uri = Services.io.newURI("file://@userChromeFile@", sss.USER_SHEET);
  if (!sss.sheetRegistered(uri, sss.USER_SHEET)) {
    sss.loadAndRegisterSheet(uri, sss.USER_SHEET);
  }
} catch(ex){
  Components.utils.reportError(ex.message);
}
