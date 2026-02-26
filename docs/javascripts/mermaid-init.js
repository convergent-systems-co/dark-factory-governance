// Initialize Mermaid.js for MkDocs Material
// Handles both instant navigation (Material's document$ observable)
// and standard page loads (DOMContentLoaded fallback)
function initMermaid() {
  if (!document.querySelector(".mermaid")) return;
  mermaid.initialize({
    startOnLoad: false,
    theme: "dark",
    themeVariables: {
      darkMode: true
    }
  });
  mermaid.run();
}

if (typeof document$ !== "undefined") {
  document$.subscribe(initMermaid);
} else {
  document.addEventListener("DOMContentLoaded", initMermaid);
}
