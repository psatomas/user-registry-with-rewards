// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract UserRegistryWithRewards {

    /*
        =========================
        EVM (Ethereum Virtual Machine)
        =========================

        This contract runs inside the EVM.

        This means:
        - There is no central server
        - Every network node executes the same code
        - The application state is globally replicated

        The EVM guarantees that contract execution
        is deterministic and immutable after deployment.
    */

    struct User {
        string name;
        address wallet;
        bool registered;
    }

    /*
        Contract administrator.

        Responsible for executing
        administrative and sensitive operations.
    */
    address public owner;

    /*
        Decentralized user database.

        Each Ethereum address represents
        a unique identity within the system.
    */
    mapping(address => User) private users;

    /*
        Internal points/reward system.

        This mapping simulates a balance
        of credits or internal platform tokens.

        Note:
        This is not a real ERC-20 token.
    */
    mapping(address => uint256) public balances;

    /*
        Anti-duplication reward control.

        Ensures each user receives
        only one initial reward.
    */
    mapping(address => bool) public rewardClaimed;

    uint256 public defaultReward = 100;
    uint256 public totalUsers;

    /*
        =========================
        EVENTS
        =========================

        Events allow important actions
        to be recorded in blockchain history
        (on-chain logs).

        They can be used by Web3 applications,
        front-end interfaces, and monitoring systems.
    */

    event UserRegistered(
        address indexed wallet,
        string name
    );

    event RewardSent(
        address indexed wallet,
        uint256 amount
    );

    event OwnershipTransferred(
        address previousOwner,
        address newOwner
    );

    event DefaultRewardUpdated(
        uint256 previousValue,
        uint256 newValue
    );

    constructor() {
        owner = msg.sender;
    }

    /*
        Security modifier.

        Restricts access to the administrator only.
    */
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "Not authorized"
        );
        _;
    }

    /*
        Verifies whether the user exists in the system.
    */
    modifier userRegistered(address wallet) {
        require(
            users[wallet].registered,
            "User not registered"
        );
        _;
    }

    function registerUser(string memory name) public {

        /*
            =========================
            GAS (user registration)
            =========================

            This function consumes gas because
            it modifies blockchain state.

            Operations performed:
            - writing into the users mapping
            - incrementing totalUsers
            - emitting an event

            Storage writes have computational
            cost inside the EVM.
        */

        require(
            !users[msg.sender].registered,
            "User already registered"
        );

        require(
            bytes(name).length > 0,
            "Invalid name"
        );

        /*
            PURPOSE:

            Create a permanent identity
            linked to the user's Ethereum address.
        */

        users[msg.sender] = User({
            name: name,
            wallet: msg.sender,
            registered: true
        });

        totalUsers++;

        emit UserRegistered(
            msg.sender,
            name
        );
    }

    function getUser(address wallet)
        public
        view
        userRegistered(wallet)
        returns (
            string memory name,
            address userWallet,
            bool registered
        )
    {

        /*
            PURPOSE:

            Allow public and transparent reading
            of registered information.

            View functions do not modify state,
            therefore they do not consume gas
            when called externally.
        */

        User memory user = users[wallet];

        return (
            user.name,
            user.wallet,
            user.registered
        );
    }

    function getBalance(address wallet)
        public
        view
        returns (uint256)
    {

        /*
            PURPOSE:

            Display the accumulated
            reward balance of the user.
        */

        return balances[wallet];
    }

    function rewardUser(address wallet)
        public
        onlyOwner
        userRegistered(wallet)
    {

        /*
            =========================
            DIFFERENCE FROM TRADITIONAL SYSTEMS
            =========================

            Traditional system:
            - centralized backend controls rules
            - database can be manually modified
            - trust is placed in the company

            Smart Contract:
            - rules execute automatically
            - execution occurs inside the EVM
            - data is permanently stored on-chain
            - trust is placed in the code
        */

        require(
            wallet != address(0),
            "Invalid address"
        );

        require(
            !rewardClaimed[wallet],
            "Reward already sent"
        );

        /*
            =========================
            GAS (reward distribution)
            =========================

            This function consumes gas because
            it modifies storage data:

            - updates user balance
            - records reward distribution

            Permanent blockchain changes
            have computational cost.
        */

        balances[wallet] += defaultReward;

        rewardClaimed[wallet] = true;

        /*
            PURPOSE:

            Distribute an initial
            economic incentive to the registered user.
        */

        emit RewardSent(
            wallet,
            defaultReward
        );
    }

    /*
        Allows changing the default reward value.
    */
    function updateDefaultReward(uint256 newValue)
        public
        onlyOwner
    {
        require(
            newValue > 0,
            "Invalid value"
        );

        uint256 previousValue = defaultReward;

        defaultReward = newValue;

        emit DefaultRewardUpdated(
            previousValue,
            newValue
        );
    }

    /*
        Allows transferring contract ownership.
    */
    function transferOwnership(address newOwner)
        public
        onlyOwner
    {
        require(
            newOwner != address(0),
            "Invalid address"
        );

        address previousOwner = owner;

        owner = newOwner;

        emit OwnershipTransferred(
            previousOwner,
            newOwner
        );
    }
}

/*
    =========================
    REAL-WORLD USE CASE
    =========================

    This contract can be used as
    a basic onboarding and incentive system
    for Web3 platforms and communities.

    New users can register through
    the registerUser() function,
    creating a permanent identity linked
    to their Ethereum address.

    After registration, the platform administrator
    can use the rewardUser() function
    to distribute credits or symbolic rewards
    as an initial incentive.

    The system guarantees:
    - unique registration per address
    - reward transparency
    - impossibility of duplicate rewards
    - traceability through on-chain events

    Practical applications:
    - Web3 educational platforms
    - DAO communities
    - onboarding programs
    - decentralized loyalty systems
    - early engagement platforms

    Before implementing more advanced mechanisms
    such as governance,
    staking, or on-chain reputation,
    this contract provides
    a simple and functional structure
    for decentralized user
    and reward management.
*/