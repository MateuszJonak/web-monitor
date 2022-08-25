import { useAuth0 } from '@auth0/auth0-react';
import { AppBar, Button, Toolbar, Typography } from '@mui/material';

export const Header: React.FC = () => {
  const { isAuthenticated, loginWithRedirect, logout } = useAuth0();
  const logoutWithRedirect = () =>
    logout({
      returnTo: window.location.origin,
    });

  return (
    <AppBar position="static">
      <Toolbar>
        <Typography variant="h6" component="div" sx={{ flexGrow: 1 }}>
          Web Monitor
        </Typography>
        {!isAuthenticated && (
          <Button color="inherit" onClick={() => loginWithRedirect()}>
            Login
          </Button>
        )}
        {isAuthenticated && (
          <Button color="inherit" onClick={() => logoutWithRedirect()}>
            Logout
          </Button>
        )}
      </Toolbar>
    </AppBar>
  );
};
