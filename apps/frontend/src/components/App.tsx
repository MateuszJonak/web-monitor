import { Header } from './Header';
import { Auth0Provider, AppState } from '@auth0/auth0-react';
import { Authorise } from './Authorise';
import { StrictMode } from 'react';
import { CssBaseline } from '@mui/material';

const onRedirectCallback = (appState?: AppState) => {
  window.history.replaceState(
    {},
    document.title,
    appState && appState.returnTo ? appState.returnTo : window.location.pathname
  );
};

export const App = () => {
  return (
    <Auth0Provider
      domain={process.env['NX_AUTH0_DOMAIN'] as string}
      clientId={process.env['NX_AUTH0_CLIENT_ID'] as string}
      audience={process.env['NX_AUTH0_AUDIENCE']}
      redirectUri={window.location.origin}
      onRedirectCallback={onRedirectCallback}
    >
      <StrictMode>
        <CssBaseline />
        <Authorise>
          <Header />
        </Authorise>
      </StrictMode>
    </Auth0Provider>
  );
};
