import { ConnectButton } from "@rainbow-me/rainbowkit";
import { useAccount } from "wagmi";

import { Attestooooooor } from "./components";

export function App() {
  /**
   * Wagmi hook for getting account information
   * @see https://wagmi.sh/docs/hooks/useAccount
   */
  const { isConnected } = useAccount();

  return (
    <>
      <img src="landing_page.jpg"/>
      {/* <h1>OP Starter Project</h1>

      <ConnectButton />

      {isConnected && (
        <>
          <hr />
          <Attestooooooor />
          <hr />
        </>
      )} */}
    </>
  );
}
