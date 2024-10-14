import XHR from "xhr2";
import { URL, format } from "node:url";

export const driver = {
  newXHR: function () {
    return new XHR();
  },
  fixupUrl: function (url, xhr) {
    if (xhr.nodejsBaseUrl === null) {
      var u = new URL(url);
      u.protocol = u.protocol || "http:";
      u.hostname = u.hostname || "localhost";
      return format(u);
    } else {
      return url || "/";
    }
  },
};
