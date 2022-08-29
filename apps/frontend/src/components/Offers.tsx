import { useQuery } from '@apollo/client';
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
    <ul>
      {data?.offers.map((offer) => (
        <li>{JSON.stringify(offer)}</li>
      ))}
    </ul>
  );
};
