let getAccessToken: () => string | null = () => null;

const setGetAccessToken = (tokenFn: () => string | null) => {
  getAccessToken = tokenFn;
};

let getRefreshToken: () => string | null = () => null;

const setGetRefreshToken = (tokenFn: () => string | null) => {
  getRefreshToken = tokenFn;
};

export {
  getAccessToken,
  setGetAccessToken,
  getRefreshToken,
  setGetRefreshToken,
};
