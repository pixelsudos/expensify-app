
jest.mock('react-native/Libraries/Animated/NativeAnimatedHelper');

jest.mock('react-native-bootsplash', () => ({
  hide: jest.fn(() => Promise.resolve(true)),
  getVisibilityStatus: jest.fn(() => Promise.resolve('visible')),
}));

jest.mock('@react-native-async-storage/async-storage', () => ({
  getItem: jest.fn(),
  setItem: jest.fn(),
  removeItem: jest.fn(),
  clear: jest.fn(),
}));

jest.mock('react-native/Libraries/Animated/NativeAnimatedHelper');

global.console = {
  ...console,
  warn: jest.fn(),
  error: jest.fn(),
};

beforeEach(() => {
  jest.clearAllMocks();
});
