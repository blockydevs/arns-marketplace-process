import { describe, it } from 'node:test';
import assert from 'node:assert';
import { readFileSync } from 'node:fs';
import path from 'path';
import { fileURLToPath } from 'url';
import AoLoader from '@permaweb/ao-loader';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PING_PONG_PROCESS_ID = 'PING_PONG_PROCESS_ID';
const SENDER_ADDRESS = 'SENDER_WALLET_ADDRESS';
const PROCESS_OWNER = 'PROCESS_OWNER_ADDRESS';
const STUB_MESSAGE_ID = 'STUB_MESSAGE_ID_12345';
const STUB_BLOCK_HEIGHT = 100;
const STUB_HASH_CHAIN = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA';

describe('Ping-Pong E2E Test (.mjs)', () => {
  it('should load a Lua process, send a Ping, and receive a Pong', async () => {
    const AOS_WASM = readFileSync(path.join(__dirname, 'aos.wasm'));
    const pocLuaScript = readFileSync(path.join(__dirname, 'poc.lua'), 'utf-8');
    const handle = await AoLoader(AOS_WASM, { format: 'wasm64-unknown-emscripten-draft_2024_02_15' });
    const env = { Process: { Id: PING_PONG_PROCESS_ID, Owner: PROCESS_OWNER, Tags: [] } };
    const DEFAULT_MESSAGE = {
      Id: STUB_MESSAGE_ID, Target: PING_PONG_PROCESS_ID, Owner: PROCESS_OWNER,
      Module: PING_PONG_PROCESS_ID, Timestamp: Date.now(),
      'Block-Height': STUB_BLOCK_HEIGHT, 'Hash-Chain': STUB_HASH_CHAIN,
    };

    const { Memory: initialMemory } = await handle(null, { ...DEFAULT_MESSAGE, Tags: [{ name: 'Action', value: 'Eval' }], Data: pocLuaScript }, env);
    
    const pingMessage = { ...DEFAULT_MESSAGE, From: SENDER_ADDRESS, Owner: SENDER_ADDRESS, Tags: [{ name: 'Action', value: 'Ping' }], Data: 'Hello, process!' };
    const result = await handle(initialMemory, pingMessage, env);

    assert.ok(result.Messages);
    assert.strictEqual(result.Messages.length, 1);
    const replyMessage = result.Messages[0];
    assert.strictEqual(replyMessage.Target, SENDER_ADDRESS);
    const pongTag = replyMessage.Tags.find((tag) => tag.name === 'Action' && tag.value === 'Pong');
    assert.ok(pongTag);
    assert.strictEqual(replyMessage.Data, 'Received ping number: 1');
  });
});