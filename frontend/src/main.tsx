import "@rainbow-me/rainbowkit/styles.css";
import { RainbowKitProvider } from "@rainbow-me/rainbowkit";
import * as React from "react";
import * as ReactDOM from "react-dom/client";
import { WagmiConfig } from "wagmi";
import { MantineProvider } from '@mantine/core';

import { App } from "./App";
import { chains, client } from "./wagmi";

/**
 * Root providers and initialization of app
 * @see https://reactjs.org/docs/strict-mode.html
 * @see https://wagmi.sh/react/WagmiConfig
 * @see https://www.rainbowkit.com/docs/installation
 */
ReactDOM.createRoot(document.getElementById("root")!).render(
  <React.StrictMode>
    <WagmiConfig client={client}>
      <RainbowKitProvider chains={chains}>
        <MantineProvider
          withGlobalStyles
          withNormalizeCSS
          theme={{
            colorScheme: 'dark',
            colors: {
              // Add your color
              deepBlue: ['#E9EDFC', '#C1CCF6', '#99ABF0' /* ... */],
              // or replace default theme color
              blue: ['#E9EDFC', '#C1CCF6', '#99ABF0' /* ... */],
            },

            shadows: {
              md: '1px 1px 3px rgba(0, 0, 0, .25)',
              xl: '5px 5px 3px rgba(0, 0, 0, .25)',
            },

            headings: {
              fontFamily: 'Roboto, sans-serif',
              sizes: {
                h1: { fontSize: '2rem' },
              },
            },
          }}
        >
          <App />
        </MantineProvider>
      </RainbowKitProvider>
    </WagmiConfig>
  </React.StrictMode>,
);
