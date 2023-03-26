import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";

import { Attestooooooor } from "./components";

import { BrowserRouter, Route, Link, Outlet, Routes } from 'react-router-dom';

import {NavbarNested} from './components/Navbar';

import Page1 from './components/Page1';
import Page2 from './components/Page2';
import Page3 from './components/Page3';

export function App() {
  /**
   * Wagmi hook for getting account information
   * @see https://wagmi.sh/docs/hooks/useAccount
   */
  const { isConnected } = useAccount();

  return (
    <BrowserRouter>
      <NavbarNested />
      {/* <nav>
        <ul>
          <li>
            <Link to="/">Page1</Link>
          </li>
          <li>
            <Link to="/page2">Page2</Link>
          </li>
          <li>
            <Link to="/page3">Page3</Link>
          </li>
        </ul>
      </nav> */}
      <div style={{float: 'right', width: '80%'}}>
        <Routes>
          <Route path="/" element={<Page1 />} />
          <Route path="/page2" element={<Page2 />} />
          <Route path="/page3" element={<Page3 />} />
        </Routes>
      </div>

      {/* <img src="landing_page.jpg" /> */}
      {/* <h1>OP Starter Project</h1>

      <ConnectButton />

      {isConnected && (
        <>
          <hr />
          <Attestooooooor />
          <hr />
        </>
      )} */}
    </BrowserRouter>
  );
}
