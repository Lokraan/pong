// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
import loadView from "./viewLoader"
import socket from "./socket"

function handleDOMContentLoaded() {
  // Get the current view name
  const viewName = document.getElementsByTagName('body')[0].dataset.jsViewName

  // Load view class and mount it
  const ViewClass = loadView(viewName)
  const view = new ViewClass()
  window.currentView = view

  window.currentView.mount()
}

function handleDocumentUnload() {
  window.currentView.unmount()
}

window.addEventListener('DOMContentLoaded', handleDOMContentLoaded, false)
window.addEventListener('unload', handleDocumentUnload, false)

// window.onbeforeunload = function(event) {
//   console.log("ok?")
//   socket.disconnect(() => {}, 1000, "hello")
// }
