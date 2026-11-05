import "@hotwired/turbo-rails"
import "controllers"
import * as bootstrap from "bootstrap"

import "trix"
import "@rails/actiontext"

// Forzar la activación manual de los elementos Trix si el DOM los ignora
window.addEventListener("DOMContentLoaded", () => {
  document.querySelectorAll("trix-editor").forEach((editor) => {
    if (!editor.hasAttribute("contenteditable")) {
      editor.setAttribute("contenteditable", "true");
    }
  });
});