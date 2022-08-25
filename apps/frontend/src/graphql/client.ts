import { ApolloClient, InMemoryCache, from, HttpLink } from '@apollo/client';
import { setContext } from '@apollo/client/link/context';

const graphQLAPIUrl = process.env['NX_GRAPHQL_API_URL'];

if (!graphQLAPIUrl) {
  throw new Error(
    'NX_GRAPHQL_API_URL is missing. This environment variables is required to setup application correctly'
  );
}

const httpLink = new HttpLink({ uri: graphQLAPIUrl });

export const createClient = (getToken: () => Promise<string>) => {
  const setAuthLink = setContext(async (_, { headers = {} }) => {
    const token = await getToken();
    return {
      headers: { ...headers, Authorization: token },
    };
  });

  return new ApolloClient({
    uri: graphQLAPIUrl,
    cache: new InMemoryCache(),
    link: from([setAuthLink, httpLink]),
  });
};
