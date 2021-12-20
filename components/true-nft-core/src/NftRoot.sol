pragma ton-solidity >=0.43.0;

pragma AbiHeader expire;
pragma AbiHeader time;

import './resolvers/IndexResolver.sol';
import './resolvers/DataResolver.sol';

import './IndexBasis.sol';

import './interfaces/IData.sol';
import './interfaces/IIndexBasis.sol';

library ArrayHelper {
    // Delete value from the `array` at `index` position
    function del(string[] array, uint index) internal pure {
        for (uint i = index; i + 1 < array.length; ++i){
            array[i] = array[i + 1];
        }
        array.pop();
    }
}


contract NftRoot is DataResolver, IndexResolver {

    address static _addrOwner;
    string static public _name;
    uint256 public _totalMinted;
    address _addrBasis;
    using ArrayHelper for string[];
    string[] public preGenerateMetadata;
    uint128 public price;
    uint128 public m_koef; 
    bool public start = false;

    constructor(TvmCell codeIndex, TvmCell codeData, uint128 pay,uint128 koef) public {
        tvm.accept();
        _codeIndex = codeIndex;
        _codeData = codeData;
        price = pay;
        m_koef = koef;
    }
    function resolveDataForThis(uint256 id) public view returns (address addrData) {
        addrData = resolveData(address(this),id,_name);
    }
    

    function getMetadata() private returns (string metadata) {
        rnd.shuffle();
        uint n = rnd.next(preGenerateMetadata.length);
        metadata = preGenerateMetadata[n];
        preGenerateMetadata.del(n);
    }

    function addMetadata(string metadata) public {
        require(msg.sender == _addrOwner, 100);
        preGenerateMetadata.push(metadata);
    }
    function startSelling() public {
        require(msg.sender == _addrOwner, 100);
        start = true;
    }

    function mintNft() public {
        require(preGenerateMetadata.length != 0, 101,"tokens is over");
        
        require(start,103,"not all tokens was upload or owner forget to start");
        
        if (msg.sender == _addrOwner) {
            tvm.accept();
        }
        else {
            tvm.rawReserve(price, 4);
            if (msg.value < price) {
                revert(102,"not enough money");
            }
        }
        price = math.muldiv(price, m_koef, 100);
        TvmCell codeData = _buildDataCode(address(this));
        TvmCell stateData = _buildDataState(codeData, _totalMinted,_name);
        
        new Data{stateInit: stateData, value: 1.3 ton}(msg.sender, _codeIndex,getMetadata());
        _totalMinted++;
    }

    function deployBasis(TvmCell codeIndexBasis) public {
        if (msg.sender == _addrOwner) {
            tvm.accept();
        }
        else {tvm.rawReserve(0 ton, 4);}
        uint256 codeHasData = resolveCodeHashData();
        TvmCell state = tvm.buildStateInit({
            contr: IndexBasis,
            varInit: {
                _codeHashData: codeHasData,
                _addrRoot: address(this)
            },
            code: codeIndexBasis
        });
        _addrBasis = new IndexBasis{stateInit: state, value: 0.4 ton}();
    }

    function destructBasis() public view {
        IIndexBasis(_addrBasis).destruct();
    }
    function sendValue(address dest, uint128 amount, bool bounce) public {
       require(msg.sender == _addrOwner, 100,"что ты творишь?)");
       dest.transfer(amount, bounce, 0);
    }
}