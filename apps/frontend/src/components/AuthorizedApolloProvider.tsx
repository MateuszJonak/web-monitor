import { ApolloProvider } from '@apollo/client';
import { useAuth0 } from '@auth0/auth0-react';
import { createClient } from '../graphql/client';

export type AuthorizedApolloProviderProps = {
  children?: React.ReactNode;
};

export const AuthorizedApolloProvider: React.FC<
  AuthorizedApolloProviderProps
> = ({ children }) => {
  const { getAccessTokenSilently } = useAuth0();

  return (
    <ApolloProvider client={createClient(getAccessTokenSilently)}>
      {children}
    </ApolloProvider>
  );
};
