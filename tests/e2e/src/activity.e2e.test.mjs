import { describe, it } from 'node:test';
import assert from 'node:assert';
import { readFileSync } from 'node:fs';
import path from 'path';
import { fileURLToPath } from 'url';
import AoLoader from '@permaweb/ao-loader';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const PROCESS_ID = 'ACTIVITY_PROCESS_ID_TEST';
const SENDER_ADDRESS = 'SENDER_WALLET_ADDRESS_TEST';
const PROCESS_OWNER = 'PROCESS_OWNER_ADDRESS_TEST';
const STUB_MESSAGE_ID = 'STUB_MESSAGE_ID_98765';
const STUB_BLOCK_HEIGHT = 200;
const STUB_HASH_CHAIN = 'BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB';

// Must match the UCM_PROCESS constant in src/activity.lua
const UCM_PROCESS = 'a3jqBgXGAqefY4EHqkMwXhkBSFxZfzVdLU1oMUTQ-1M';

// Helper: build a Lua script that preloads our local utils.lua under module name 'utils'
function buildBootstrapLua() {
  const utilsLua = readFileSync(path.join(__dirname, '../../../src/utils.lua'), 'utf-8');
  const activityLua = readFileSync(path.join(__dirname, '../../../src/activity.lua'), 'utf-8');
  // Ensure JSON/json interop across modules
  const jsonAlias = `
    do
      local ok, j = pcall(require, 'json')
      if ok and j then package.loaded['JSON'] = j end
      local ok2, j2 = pcall(require, 'JSON')
      if ok2 and j2 then package.loaded['json'] = j2 end
    end
  `;
  const preloadUtils = `
    package.preload['utils'] = function()
      ${utilsLua}
    end
  `;
  return `${jsonAlias}\n${preloadUtils}\n${activityLua}`;
}

function makeDefaultMessage(overrides = {}) {
  return {
    Id: STUB_MESSAGE_ID, Target: PROCESS_ID, Owner: PROCESS_OWNER,
    Module: PROCESS_ID, Timestamp: Date.now(),
    'Block-Height': STUB_BLOCK_HEIGHT, 'Hash-Chain': STUB_HASH_CHAIN,
    ...overrides,
  };
}

describe('Activity E2E Test using src/activity.lua', () => {
  it('should accept a listed order and return it via Get-Listed-Orders', async () => {
    const AOS_WASM = readFileSync(path.join(__dirname, 'aos.wasm'));
    const handle = await AoLoader(AOS_WASM, { format: 'wasm64-unknown-emscripten-draft_2024_02_15' });

    const env = { Process: { Id: PROCESS_ID, Owner: PROCESS_OWNER, Tags: [] } };
    const evalMsg = makeDefaultMessage({ Tags: [{ name: 'Action', value: 'Eval' }], Data: buildBootstrapLua() });

    const { Memory } = await handle(null, evalMsg, env);

    // 1) Push one listed order using the public update handler (must come from UCM_PROCESS)
    const order = {
      Id: 'ORDER-1',
      DominantToken: 'TOKEN_A',
      SwapToken: 'TOKEN_B',
      Sender: 'SELLER_ADDR_X',
      Quantity: '1000000',
      Price: '2500',
      CreatedAt: Math.floor(Date.now() / 1000),
      Domain: 'example.test',
      OrderType: 'fixed',
      ExpirationTime: Math.floor(Date.now() / 1000) + 3600,
      OwnershipType: 'permanent'
    };

    const updateMsg = makeDefaultMessage({
      From: UCM_PROCESS,
      Owner: UCM_PROCESS,
      Tags: [{ name: 'Action', value: 'Update-Listed-Orders' }],
      Data: JSON.stringify({ Order: order })
    });

    const afterUpdate = await handle(Memory, updateMsg, env);
    assert.ok(afterUpdate); // state advanced

    // 2) Read listed orders
    const readMsg = makeDefaultMessage({
      From: SENDER_ADDRESS,
      Owner: SENDER_ADDRESS,
      Tags: [{ name: 'Action', value: 'Get-Listed-Orders' }],
      Data: ''
    });

    const readRes = await handle(afterUpdate.Memory, readMsg, env);

    assert.ok(readRes.Messages, 'Expected at least one message in response');
    const reply = readRes.Messages.find(m => m.Target === SENDER_ADDRESS);
    assert.ok(reply, 'Expected a reply to come back to the query sender');
    const actionTag = reply.Tags && reply.Tags.find(t => t.name === 'Action');
    assert.ok(actionTag && actionTag.value === 'Read-Success', 'Expected Read-Success action tag');

    const payload = JSON.parse(reply.Data);
    assert.strictEqual(typeof payload, 'object');
    assert.ok(Array.isArray(payload.items));
    assert.strictEqual(payload.totalItems, 1);
    assert.strictEqual(payload.items.length, 1);

    const item = payload.items[0];
    assert.strictEqual(item.OrderId, 'ORDER-1');
    assert.strictEqual(item.Status, 'active');
    assert.strictEqual(item.Domain, 'example.test');
  });
});
