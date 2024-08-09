import { argon2id } from 'hash-wasm';
import * as crypto from 'node:crypto';
import * as _ from 'underscore';

interface Solution {
  number: number;
  took: number;
  worker?: boolean;
}

interface ClientPayload {
  challenge_id: string;
  min: number;
  complexity: number;
  salt: string;
  hash: string;
}

const min = 0;
const complexity = 1000;

async function createTestChallenge(): Promise<{ 
  solution: string, 
  challenge: string,
  salt: string,
}> {

  // salt is a buffer containing random bytes
  const binary_salt = new Uint8Array(16);
  crypto.webcrypto.getRandomValues(binary_salt);

  const salt = Buffer.from(binary_salt).toString('base64');
  console.log(`[setting salt to ${salt}]`);

  // the actual solution of the challenge is a random int
  const solution = zeroPad(Math.round(Math.random() * complexity), 6);
  console.log(`[setting solution to ${solution}]`);

  const challenge = await argon2idChallenge(salt, solution);
  console.log(`[setting challenge to ${challenge}]`);
  return { solution, challenge, salt };
}

// generate int numbers with padded zeros
const zeroPad = (num: number, places: number) => String(num).padStart(places, '0');

async function argon2idChallenge(
  salt: string,
  solution: string,
): Promise<string> {
    // generate key
    // https://www.npmjs.com/package/hash-wasm#string-encoding-pitfalls
    return argon2id({
        password: solution.normalize(),
        salt,
        parallelism: 1,
        iterations: 1, // For more security, you should usually raise memory parameter, not iterations.
        memorySize: 10*1000, // 10 MB
        hashLength: 32, // output size = 32 bytes
        outputType: 'hex',
    });
}

async function solveChallenge(
  payload: ClientPayload,
): Promise<Solution | null> {

  const startTime = Date.now();
  let nonce = payload.min;

  while (nonce < complexity) {
    console.log('---| ', nonce);
    // Format nounce to add padding
    const current_solution = zeroPad(nonce, 6);
    const current_hash =
      await argon2idChallenge(payload.salt, current_solution);
    console.log('---| ', current_hash);
    console.log('---| ', payload.hash);

    if (_.isEqual(current_hash, payload.hash)) {
      return {
        number: nonce,
        took: Date.now() - startTime,
      } as Solution;
    }

    nonce++;
  }

  return null;
}

async function main() {
    try {
        console.log('THIS PART WILL RUN SERVER SIDE:');
        const challenge = await createTestChallenge();
        console.log('CHALLENGE: ', challenge);

        const challenge_id = 'randomly_generated_id';
        const client_payload: ClientPayload = {
          challenge_id,
          min,
          complexity,
          salt: challenge.salt,
          hash: challenge.challenge,
        };

        console.log('THIS PART WILL RUN ON CLIENT:');
        const solution = await solveChallenge(client_payload);

        if (!solution) throw 'NON-SOLVABLE CHALLANGE'
        console.log(`Solution is ${solution.number}, it took ${solution.took} ms to compute`);
    } catch(error) {
        console.error(error);
    }
}

main()
