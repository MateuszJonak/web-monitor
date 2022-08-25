import { gql, useQuery } from '@apollo/client';

const GET_OFFERS = gql`
  query Offers {
    offers {
      link
      address
      area
      category
      createdAt
      id
      perMeter
      price
    }
  }
`;

export const Offers = () => {
  const { data, loading, error } = useQuery(GET_OFFERS);

  if (error) {
    return <div>Oops... {error.message}</div>;
  }

  if (loading) {
    return <>loading offers...</>;
  }

  return (
    <ul>
      {data.offers.map((offer: Record<string, unknown>) => (
        <li>{JSON.stringify(offer)}</li>
      ))}
    </ul>
  );
};
