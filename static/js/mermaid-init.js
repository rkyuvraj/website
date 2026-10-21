(() => {
  const root = document.documentElement;
  const diagrams = Array.from(document.querySelectorAll('pre.mermaid'), element => ({
    element, source: element.textContent
  }));
  // Abridge's dark-default switcher adds .switch for light mode.
  const currentTheme = () => root.classList.contains('switch') ? 'default' : 'dark';
  let renderedTheme;
  let rendering = false;
  async function render() {
    if (rendering) return;
    rendering = true;
    try {
      while (renderedTheme !== currentTheme()) {
        renderedTheme = currentTheme();
        mermaid.initialize({ startOnLoad: false, securityLevel: 'strict', theme: renderedTheme });
        for (const { element, source } of diagrams) {
          element.removeAttribute('data-processed');
          element.textContent = source;
        }
        await mermaid.run({ nodes: diagrams.map(item => item.element) });
      }
    } catch (error) {
      console.error('Unable to render Mermaid diagram', error);
    } finally {
      rendering = false;
    }
  }
  new MutationObserver(render).observe(root, { attributes: true, attributeFilter: ['class', 'data-theme'] });
  render();
})();
