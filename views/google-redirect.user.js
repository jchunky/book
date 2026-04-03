// ==UserScript==
// @name         Google Redirect Notice Auto-Follow
// @namespace    https://github.com/jasonc
// @version      1.0
// @description  Automatically follows the destination URL on Google's redirect notice page
// @match        https://www.google.com/url?*
// @grant        none
// @run-at       document-start
// ==/UserScript==

(function () {
  "use strict";
  const url = new URL(window.location.href);
  const destination = url.searchParams.get("q") || url.searchParams.get("url");
  if (destination) {
    window.location.replace(destination);
  }
})();
