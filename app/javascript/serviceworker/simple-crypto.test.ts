import crypto from "crypto";
import { SimpleCrypto } from "./simple-crypto";

// Stub out TextEncoder, TextDecoder, and crypto.subtle for Jest.
// These are available in the browser, but not in Node.
global.TextEncoder = require("util").TextEncoder;
global.TextDecoder = require("util").TextDecoder;
Object.defineProperty(global.self, "crypto", {
  value: {
    getRandomValues: (arr: any) => crypto.randomBytes(arr.length),
    subtle: crypto.webcrypto.subtle,
  },
});

describe("SimpleCrypto", () => {
  const passphrase = "my-passphrase";
  const salt = "my-salt";
  const payload = "Hello, world! 🌎";
  let secret: SimpleCrypto;

  beforeEach(async () => {
    secret = new SimpleCrypto(passphrase, salt);
    await secret.init();
  });

  test("encrypts and decrypts a payload correctly", async () => {
    const encrypted = await secret.encrypt(payload);
    expect(encrypted).not.toEqual(payload);

    const decrypted = await secret.decrypt(encrypted);
    expect(decrypted).toEqual(payload);
  });

  test("works with a large payload", async () => {
    const largePayload = new Array(500000).fill("x").join("");
    const encrypted = await secret.encrypt(largePayload);
    expect(encrypted).not.toEqual(largePayload);

    const decrypted = await secret.decrypt(encrypted);
    expect(decrypted).toEqual(largePayload);
  });
});
