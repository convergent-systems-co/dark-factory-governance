// Initialize Mermaid.js for MkDocs Material
// Handles both instant navigation (Material's document$ observable)
// and standard page loads (DOMContentLoaded fallback)
function initMermaid() {
  if (!document.querySelector(".mermaid")) return;
  mermaid.initialize({
    startOnLoad: false,
    theme: "base",
    themeVariables: {
      darkMode: true,
      background: "#2E3440",
      primaryColor: "#5E81AC",
      primaryTextColor: "#ECEFF4",
      primaryBorderColor: "#4C566A",
      secondaryColor: "#434C5E",
      secondaryTextColor: "#D8DEE9",
      secondaryBorderColor: "#4C566A",
      tertiaryColor: "#3B4252",
      tertiaryTextColor: "#D8DEE9",
      tertiaryBorderColor: "#4C566A",
      lineColor: "#81A1C1",
      textColor: "#ECEFF4",
      mainBkg: "#3B4252",
      nodeBorder: "#81A1C1",
      clusterBkg: "#3B4252",
      clusterBorder: "#4C566A",
      titleColor: "#88C0D0",
      edgeLabelBackground: "#3B4252",
      nodeTextColor: "#ECEFF4"
    }
  });
  mermaid.run();
}

if (typeof document$ !== "undefined") {
  document$.subscribe(initMermaid);
} else {
  document.addEventListener("DOMContentLoaded", initMermaid);
}
