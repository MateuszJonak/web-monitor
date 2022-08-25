import { useAuth0 } from '@auth0/auth0-react';

export type AuthoriseProps = {
  children: React.ReactElement;
};

export const Authorise: React.FC<AuthoriseProps> = ({ children }) => {
  const { isLoading, error } = useAuth0();

  if (error) {
    return <div>Oops... {error.message}</div>;
  }

  if (isLoading) {
    return <div>loading...</div>;
  }

  return children;
};
