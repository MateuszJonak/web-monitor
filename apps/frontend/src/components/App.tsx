import { Header } from './Header';
import { Auth0Provider, AppState } from '@auth0/auth0-react';
import { Auth0Loader } from './Auth0Loader';
import { StrictMode } from 'react';
import { CssBaseline } from '@mui/material';
import { AuthorizedApolloProvider } from './AuthorizedApolloProvider';
import { Offers } from './Offers';

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
      <AuthorizedApolloProvider>
        <StrictMode>
          <CssBaseline />

          <Header />
          <Auth0Loader>
            <Offers />
          </Auth0Loader>
        </StrictMode>
      </AuthorizedApolloProvider>
    </Auth0Provider>
  );
};
