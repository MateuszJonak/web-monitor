import { useAuth0 } from '@auth0/auth0-react';

export type Auth0LoaderProps = {
  children: React.ReactElement;
};

export const Auth0Loader: React.FC<Auth0LoaderProps> = ({ children }) => {
  const { isLoading, error, isAuthenticated } = useAuth0();

  if (error) {
    return <div>Oops... {error.message}</div>;
  }

  if (isLoading) {
    return <div>loading...</div>;
  }

  if (isAuthenticated) {
    return children;
  }

  return null;
};
