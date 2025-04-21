export default async () => {
  window.Proscenium = window.Proscenium || {};

  if (!window.Proscenium.UJS) {
    const classPath =
      "/node_modules/@rubygems/proscenium-ui/lib/proscenium/ui/ujs/class.js";
    const module = await import(classPath);
    window.Proscenium.UJS = new module.default();
  }
};
