import { Elm } from '../Main.elm';

export const run = () => {
  // Initialize Elm app
  const app = Elm.Main.init({
    node: document.getElementById('root'),
    flags: {
      screenSize: [window.innerWidth, window.innerHeight],
      url: window.location.href,
    },
  });

  const {
    interopFromElm: { subscribe },
    interopToElm: { send },
  } = app.ports;

  // React to any messages coming from Elm
  subscribe((event) => {
    switch (event.tag) {
      case 'APP_INIT': {
        return undefined;
      }
      default: {
        return undefined;
      }
    }
  });

  return app;
};
