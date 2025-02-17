string name = "PDHWToken";
string symbol = "PDHW";

uint8_t decimals = 6;
int256_t ltcr_inr = 6000000;
int256_t pending_payments = 51*1e5;
int256_t transaction_fee = 1000000;

using wallet_id_t = int160_t;

wallet_id_t pending_payments_wallet_id;
map<wallet_id_t, int256_t> balances;
map<wallet_id_t, bool> negative_balance_allowed;

__attribute__((only_owner)) void set_ltcr_inr(int256_t val) {
    ltcr_inr = val;
    balances[0] = pending_payments / ltcr_inr;
}

__attribute__((only_owner)) void set_balance(wallet_id_t wallet_id, int256_t balance) {
    assert(pending_payments_wallet_id != wallet_id);
    balances[wallet_id] = balance;
}

__attribute__((only_wallet_id(from))) void transfer(wallet_id_t from, wallet_id_t to, int256_t amount) {
    assert(negative_balance_allowed[from] || (amount + fee) <= balances[from]);
    balances[from] -= amount + fee;
    balances[to] += amount;
}

__attribute__((only_owner)) void allow_negative_balance(wallet_id_t wallet_id) {
    negative_balance_allowed[wallet_id] = true;
}

