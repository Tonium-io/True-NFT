
pragma ton-solidity >=0.47.0;
pragma AbiHeader expire;
pragma AbiHeader time;
pragma AbiHeader pubkey;
// import required DeBot interfaces and basic DeBot contract.

import "https://raw.githubusercontent.com/tonlabs/debots/main/Debot.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/Terminal/Terminal.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/Sdk/Sdk.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/ConfirmInput/ConfirmInput.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/Menu/Menu.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/AddressInput/AddressInput.sol";
import "https://raw.githubusercontent.com/tonlabs/DeBot-IS-consortium/main/AmountInput/AmountInput.sol";

interface IMultisig {
    function submitTransaction(
        address  dest,
        uint128 value,
        bool bounce,
        bool allBalance,
        TvmCell payload)
    external returns (uint64 transId);
}

interface NftRoot {
    function price() external returns (uint128 price);
    function _totalMinted() external returns (uint256 _totalMinted);
    function _name() external returns (bytes _name);
    function resolveDataForThis(
        uint256 id
    ) external returns (address addrData);
    function mintNft() external;
}



contract HelloDebot is Debot {
    bytes m_icon;
    address m_wallet;
    uint128 m_amount;
    address m_nftroot;
    uint128 m_price;
    uint256 m_id;
    bytes m_name;
    function setIcon(bytes icon) public {
        require(msg.pubkey() == tvm.pubkey(), 100);
        tvm.accept();
        m_icon = icon;
    }

    /// @notice Returns Metadata about DeBot.
    function getDebotInfo() public functionID(0xDEB) override view returns(
        string name, string version, string publisher, string caption, string author,
        address support, string hello, string language, string dabi, bytes icon
    ) {
        name = "Nefirtiti debot minting";
        version = "0.0.1";
        publisher = "Tonium";
        caption = "";
        author = "Tonium";
        support = address.makeAddrStd(0, 0x0);
        hello = "It help you mint in neferiti";
        language = "en";
        dabi = m_debotAbi.get();
        icon = m_icon;
    }

    function getRequiredInterfaces() public view override returns (uint256[] interfaces) {
        return [ Terminal.ID ];
    }

    function setUserInput(string value) public {
        Terminal.print(0, format("You have entered \"{}\"", value));
    }

    function start() public override {
        // print string to user.
        Terminal.print(tvm.functionId(getaddddr), "Hello, there!");
        // input string from user and define callback that receives entered string.
        // MenuItem[] items;
        // items.push( MenuItem("Mint token", "", tvm.functionId(prepreprepare)) );
        // Menu.select("What's next?", "", items);
        
        
    }
    function getaddddr() public {
        AddressInput.get(tvm.functionId(addressMain), "Which wallet do you want to work with?");
    }
    function addressMain(address value) public {
        m_wallet = value;
        Sdk.getAccountCodeHash(tvm.functionId(prepreprepare), m_wallet);
        // print string to user.
    }


    function checkWalletHash(uint256 code_hash) public {
        // safe msig
        if (code_hash != 0x80d6c47c4a25543c9b397b71716f3fae1e2c5d247174c52e2c19bd896442b105 &&
        // surf msig
            code_hash != 0x207dc560c5956de1a2c1479356f8f3ee70a59767db2bf4788b1d61ad42cdad82 &&
        // 24 msig
            code_hash != 0x7d0996943406f7d62a4ff291b1228bf06ebd3e048b58436c5b70fb77ff8b4bf2 &&
        // 24 setcode msig
            code_hash != 0xa491804ca55dd5b28cffdff48cb34142930999621a54acee6be83c342051d884 &&
        // setcode msig
            code_hash != 0xe2b60b6b602c10ced7ea8ede4bdf96342c97570a3798066f3fb50a4b2b27a208) {
            start();
            return;
        }
        MenuItem[] items;
        items.push( MenuItem("Mint token", "", tvm.functionId(prepreprepare)) );
        Menu.select("What's next?", "", items);
    }

    function prepreprepare() public {
        //Sdk.getAccountCodeHash(tvm.functionId(checkWalletHash), m_wallet);
        AddressInput.get(tvm.functionId(preprepare), "Address of nftroot");
        
    }

    function preprepare(address value) public {
        m_nftroot = value;
        // uint128 p = NftRoot(m_nftroot).price();
        _price(tvm.functionId(prepare), value);
        
    }

    function prepare(uint128 price) public {
        m_price = price;
        Terminal.print(tvm.functionId(getTotalMinted), format("{} price",m_price));
    }
    function getTotalMinted() public {
        _total_minted(tvm.functionId(getTotalMinted_d),m_nftroot);
    }

    function getTotalMinted_d(uint256 _totalMinted) public {
        m_id = _totalMinted;
        _name(tvm.functionId(getName),m_nftroot);
    }

    function getName(bytes _name) public {
        m_name = _name;
        mintNft(m_nftroot,m_price);
    }



    function pare(address addrData) public {
        Terminal.print(tvm.functionId(getaddddr), format("Its ok you got nft, Your address of token: {}",addrData));
    }

    function mintNft(address adr, uint128 value) public {
        optional(uint256) none;
        optional(uint256) pubkey = 0;
        IMultisig(m_wallet).submitTransaction{
            abiVer: 2,
            extMsg: true,
            sign: true,
            pubkey: pubkey,
            time: uint64(now),
            expire: 0,
            callbackId: tvm.functionId(onSuccess),
            onErrorId: tvm.functionId(onError)
        }
        (adr, value + 2 ton, true, false, tvm.encodeBody(NftRoot.mintNft));
    }

    function onSuccess(uint64 transId) public {
        _get_address(tvm.functionId(pare),m_nftroot,m_id);

    }

    function onError(uint32 sdkError, uint32 exitCode) public {
        Terminal.print(tvm.functionId(getaddddr), format("Some error exitCode {} sdkError {}", exitCode, sdkError));
    }

    function _price(uint32 answerId,address nftroot) private view {
        optional(uint256) none;
        NftRoot(nftroot).price{
            abiVer: 2,
            extMsg: true,
            sign: false,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: tvm.functionId(onError)
        }();
    }

    function _total_minted(uint32 answerId,address nftroot) private view {
        optional(uint256) none;
        NftRoot(nftroot)._totalMinted{
            abiVer: 2,
            extMsg: true,
            sign: false,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: tvm.functionId(onError)
        }();
    }

    function _name(uint32 answerId,address nftroot) private view {
        optional(uint256) none;
        NftRoot(nftroot)._name{
            abiVer: 2,
            extMsg: true,
            sign: false,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: tvm.functionId(onError)
        }();
    }


    function _get_address(uint32 answerId,address nftroot, uint256 id) private view {
        optional(uint256) none;
        NftRoot(nftroot).resolveDataForThis{
            abiVer: 2,
            extMsg: true,
            sign: false,
            time: uint64(now),
            expire: 0,
            callbackId: answerId,
            onErrorId: tvm.functionId(onError)
        }(id);
    }
    
}