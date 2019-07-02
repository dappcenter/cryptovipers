pragma solidity 0.5.3;
// Importing OpenZeppelin's ERC-721 and SafeMath Implementation
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/token/ERC721/ERC721Full.sol";
import "https://github.com/OpenZeppelin/openzeppelin-solidity/contracts/math/SafeMath.sol";

contract ViperToken is ERC721Full {
    using SafeMath for uint256;
    
    struct Viper {
        uint8 genes;
        uint256 matronId;
        uint256 sireId;
    }
    
    // list of existing vipers
    Viper[] public vipers;
    
    // event emitted whenever a new viper is created
    event Birth (
        address owner,
        uint256 viperId,
        uint256 matronId,
        uint256 sireId,
        uint8 genes
    );
    
    // initializing an ERC-721 token named 'Vipers' with a symbol VPR 
    constructor () ERC721Full("Vipers", "VPR") public {
    }
    
    // fallback function
    function() external payable {
    }
    
    /** @dev Function to determine viper's characteristics
     * @param matron ID of viper's matron (one parent)
     * @param sire ID of viper's sire (other parent)
     * @return the viper's genes in the form of uint8
     */
     function generateViperGenes (uint256 matron, uint256 sire) internal pure returns (uint8) {
         return uint8(matron.add(sire)) % 6 + 1;
     }
     
     /** @dev funtion to create a new viper
      * @param matron id of new vipers matron (one parent)
      * @param sire id of new vipers sire (other parent)
      * @param viperOwner address of new viper's owner
      * @return the new viper's id 
      */
      function createViper(uint256 matron, uint256 sire, address viperOwner) internal returns (uint) {
          require(viperOwner != address(0));
          uint8 newGenes = generateViperGenes(matron, sire);
          Viper memory newViper = Viper ({
              genes: newGenes,
              matronId: matron,
              sireId: sire
          });
          uint256 newViperId = vipers.push(newViper).sub(1);
          super._mint(viperOwner, newViperId);
          emit Birth (viperOwner, newViperId, newViper.matronId, newViper.sireId, newViper.genes);
          return newViperId;
      }
      
      /** @dev Function to allow user to buy a new viper (calls createViper())
        * @return The new viper's ID
        */
        function buyViper() external payable returns (uint256) {
            require(msg.value == 0.02 ether);
            return createViper(0, 0, msg.sender);
        }
      
      /** @dev function to breed two vipers to create a new one
       * @param matronId of new viper's matron
       * @param sireId of new viper's sire 
       * @return the new viper's id 
       */
       function breedVipers (uint256 matronId, uint256 sireId) external payable returns (uint256) {
           require(msg.value == 0.05 ether);
           return createViper(matronId, sireId, msg.sender);
       }
       
       /** @dev Function to retrieve a specific viper's details
        * @param viperId of the viper whose details are to be retrieved
        * @return an array, [viper's id, viper's genes, matronId, sireId]
        */
        function getViperDetails (uint256 viperId) external view returns (uint256, uint8, uint256, uint256) {
            Viper storage viper = vipers[viperId];
            return (viperId, viper.genes, viper.matronId, viper.sireId);
        }
        
        /** @dev Function to get a list of owned vipers' IDs 
         * @return a uint array which contains ids of all owned vipers 
         */
         function ownedVipers () external view returns(uint256[] memory) {
            uint256 viperCount = balanceOf(msg.sender);
            if (viperCount == 0) {
                return new uint256[](0);
            } else {
                uint256[] memory result = new uint256[](viperCount);
                uint256 totalVipers = vipers.length;
                uint256 resultIndex = 0;
                uint256 viperId = 0;
                while (viperId < totalVipers) {
                    if (ownerOf(viperId) == msg.sender) {
                        result[resultIndex] = viperId;
                        resultIndex = resultIndex.add(1);
                    }
                    viperId = viperId.add(1);
                }
                return result;
            }
         }
}