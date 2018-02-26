CREATE OR REPLACE PACKAGE blockchain_api as

l_difficulty constant number := 4;

procedure initialise;

procedure calculateHash;

procedure mineBlock;

procedure getLatestBlock;

function isChainValid
return boolean;

procedure isEntireChainValid;

end;

/
