import { useQuery } from '@apollo/client';
import styled from '@emotion/styled';
import {
  Box,
  Card,
  CardContent,
  CardMedia,
  Container,
  Divider,
  Link,
  Stack,
  Typography,
} from '@mui/material';
import { OffersQueryDocument } from '../graphql/operations/offers.generated';

export const Offers = () => {
  const { data, loading, error } = useQuery(OffersQueryDocument);

  if (error) {
    return <div>Oops... {error.message}</div>;
  }

  if (loading) {
    return <>loading offers...</>;
  }

  return (
    <Container maxWidth="md">
      <Box mt={2}>
        <List>
          {data?.offers.map((offer) => (
            <li key={offer?.id}>
              <Card sx={{ display: 'flex', minHeight: 180 }}>
                <CardMedia
                  component="img"
                  sx={{ width: 280, aspectRatio: '16 / 9' }}
                  image={offer?.imageSource}
                />
                <Box sx={{ display: 'flex', flexDirection: 'column' }}>
                  <CardContent sx={{ flex: '1 0 auto' }}>
                    <Stack spacing={2}>
                      <Typography
                        component={Link}
                        href={offer?.link}
                        target="_blank"
                        rel="noreferrer"
                        underline="hover"
                        variant="h5"
                      >
                        {offer?.title}
                      </Typography>
                      <Typography
                        variant="subtitle1"
                        color="text.secondary"
                        component="div"
                      >
                        {offer?.address}
                      </Typography>
                      <Stack
                        direction="row"
                        divider={<Divider orientation="vertical" flexItem />}
                        spacing={2}
                      >
                        {[
                          offer?.price,
                          offer?.perMeter,
                          offer?.roomCount,
                          offer?.area,
                        ].map((item, index) => (
                          <Typography
                            key={index}
                            variant="subtitle2"
                            color="text.secondary"
                            component="div"
                          >
                            {item}
                          </Typography>
                        ))}
                      </Stack>
                    </Stack>
                  </CardContent>
                </Box>
              </Card>
            </li>
          ))}
        </List>
      </Box>
    </Container>
  );
};

const List = styled.ul`
  list-style-type: none;
  margin: auto;
  padding: 0;

  > li {
    margin-bottom: 16px;
  }
`;
