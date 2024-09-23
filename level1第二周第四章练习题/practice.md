
# 如下合约中，test 返回什么?

```
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
contract Demo {
    //当给返回值赋值后，并且有个return，以最后的return为主
    function test() public pure returns (uint256 mul) {
        uint256 a = 10;
        mul = 100;
        return a;
    }
}
```
# 解答：返回10，虽然 mul 是函数test返回参数，但是函数内部声明 a ，并返回 a ，没有返回 mul

# 函数参数使用时候有哪些需要注意的？
  - 引用类型需要 `memory`/`calldata`
  - 函数参数可以当作为本地变量，也可用在等号左边被赋值。
  - 外部函数不支持多维数组，如果原文件加入 p `ragma abicoder v2;` 可以启用 ABI v2 版编码功能，这此功能可用。

# 解答：对于引用类型，memory适用于临时存储，而calldata用于从外部传入的数据。例如，function example(uint[] memory arr)表示arr在函数内部可以修改，而function example(uint[] calldata arr)则表示arr只能读取，不能修改。
contract Example {
    function modifyArray(uint[] memory arr) public pure returns (uint) {
        arr[0] = 10; // 可以修改
        return arr[0];
    }
}
contract Example {
    function readArray(uint[] calldata arr) public pure returns (uint) {
        // arr[0] = 10; // 这会导致编译错误，因为 calldata 不能修改
        return arr[0]; // 可以读取
    }
}
memory: 适合需要修改的数据，但由于其分配和修改需要额外的 gas，使用时要注意费用。
calldata: 适合只读取的场景，尤其在处理外部输入时，可以显著节省 gas，因为它避免了内存分配和修改的开销。

# 创建一个 `Utils` 合约，其中有 `sum` 方法，传入任意数量的数组，都可以计算出求和结果。
# 解答 ：
contract Utils {
    function sum(uint[][] calldata arrays) external pure returns (uint) {
        uint total = 0;
        for (uint i = 0; i < arrays.length; i++) {
            for (uint j = 0; j < arrays[i].length; j++) {
                total += arrays[i][j];
            }
        }
        return total;
    }
}

# 函数既可以定义在合约内部，也可以定义在合约外部，两种方式的区别是什么？
  - 合约之外的函数（也称为“自由函数”）始终具有隐式的 `internal` 可见性。 它们的代码包含在所有调用它们合约中，类似于内部库函数。
  - 在合约之外定义的函数仍然在合约的上下文内执行。他们仍然可以访问变量 `this` ，也可以调用其他合约，将其发送以太币或销毁调用它们合约等其他事情。与在合约中定义的函数的主要区别为：自由函数不能直接访问存储变量和不在他们的作用域范围内函数。
# 解答：
1、合约内部的函数
  contract MyContract {
    uint private value;

    function setValue(uint _value) public {
        value = _value; // 可以直接访问状态变量
    }

    function getValue() public view returns (uint) {
        return value; // 直接访问状态变量
    }
}
2、合约外部的函数（自由函数）
// 自由函数定义
function increment(uint _value) internal pure returns (uint) {
    return _value + 1;
}

// 调用自由函数的合约
contract AnotherContract {
    function incrementValue(uint _value) public pure returns (uint) {
        return increment(_value); // 调用自由函数
    }
}


# 函数的构造函数有什么特点？
  - 它仅能在智能合约部署的时候调用一次，创建之后就不能再次被调用。
  - 构造函数是可选的，只允许有一个构造函数，这意味着不支持重载。（普通函数支持重载）
  - ：在合约创建的过程中，它的代码还是空的，所以直到构造函数执行结束，我们都不应该在其中调用合约自己的函数。(可以直接写函数名调用，但是不推荐调用，不可以通过 this 来调用函数，因为此时真实的合约实例还没有被创建。)
# 解答：构造函数的特点
1、一次性调用:
    构造函数在智能合约部署时被调用，仅能执行一次。合约部署后，构造函数无法再次调用。
2、可选性和唯一性:
    构造函数是可选的。如果不定义，Solidity 会提供一个默认构造函数。
    合约只能有一个构造函数，不支持重载（即同名不同参数的构造函数）。
3、不推荐调用合约内的其他函数:
    在构造函数执行期间，合约的状态尚未完全初始化，因此不推荐在构造函数中调用合约自己的其他函数。
    直接调用函数名是可能的，但容易导致不可预测的行为。使用 this 调用其他函数是禁止的，因为此时合约实例尚未创建。
contract MyContract {
    uint public value;
    // 构造函数
    constructor(uint _value) {
        value = _value; // 合法，直接设置状态变量
        // myFunction(); // 不推荐这样做
        // this.myFunction(); // 不允许，合约实例还未创建
    }

    function myFunction() public pure returns (string memory) {
        return "Hello!";
    }
}
总结：构造函数用于初始化合约状态，并设置初始值。

# 构造函数有哪些用途？
  - 用来设置管理账号，Token 信息等可以自定义，并且以后永远不需要修改的数据。
  - 可以用来做初识的权限设置，避免后续没办法 owner/admin 地址。、
# 解答：
1、初始化状态变量:
    用于设置合约中的初始状态变量，例如管理账号、Token 名称、符号和总供应量等。这些信息通常在合约创建后不会更改。
constructor(string memory _name, string memory _symbol, uint _totalSupply) {
    name = _name;
    symbol = _symbol;
    totalSupply = _totalSupply;
}
2、设置权限管理:
    可以在构造函数中指定合约的管理者（例如 owner 或 admin）地址，以便在后续操作中管理合约的权限。
address public owner;
constructor() {
    owner = msg.sender; // 将合约部署者设置为所有者
}

# 合约内调用外部有哪些？应该改为：外部调用合约内函数有哪些方式？
  - 也可以使用表达式 `this.g(8)`; 和 `c.g(2)`; 进行调用，其中 c 是合约实例， g 合约内实现的函数，这两种方式调用函数，称为“外部调用”，它是通过消息调用来进行，而不是直接的代码跳转。请注意，不可以在构造函数中通过 `this` 来调用函数，因为此时真实的合约实例还没有被创建。
# 解答：
1、通过 this 关键字调用：你可以使用 this.externalFunction(8); 来调用合约内定义的函数 externalFunction。这种调用方式是通过消息传递的，意味着它会产生一个新的交易。
contract Example {
    uint256 public value;

    function callThis() public {
        // 通过 this 调用 externalFunction
        this.externalFunction(8); // 产生新的交易
    }
    function externalFunction(uint256 x) public {
        value = x; // 修改合约状态
    }
}
2、通过合约实例调用：如果你有其他合约的实例 c，可以用 c.g(2); 来调用 c 合约内的函数 g。同样，这也是一种外部调用。
contract ContractB {
    // 一个简单的状态变量
    uint public value;

    // 更新状态变量的函数
    function setValue(uint _value) external {
        value = _value;
    }
}

contract ContractA {
    // ContractB的实例
    ContractB public contractB;

    // 构造函数初始化ContractB的地址
    constructor(address _contractBAddress) {
        contractB = ContractB(_contractBAddress);
    }

    // 调用ContractB的setValue函数
    function updateValue(uint _value) external {
        contractB.setValue(_value);  // 通过实例调用
    }
}
js:
// 假设我们已经部署了ContractB，并得到了它的地址
const contractBAddress = "0x..."; // ContractB的地址
const contractA = await ContractA.deploy(contractBAddress);
// 调用updateValue来更新ContractB的value
await contractA.updateValue(42);
# 注意事项
1、在构造函数中不能使用 this 调用函数，因为此时合约的真实实例尚未创建。
2、所有外部调用都会消耗Gas，并可能引发状态变化，因此需要注意Gas限制和异常处理。

# 从一个合约到另一个合约的函数调用会创建交易么？
  - 从一个合约到另一个合约的函数调用不会创建自己的交易, 它是作为整个交易的一部分的消息调用。
# 解答：从一个合约到另一个合约的函数调用不会单独创建交易，而是作为整个交易的一部分进行处理。这种调用被称为“内部交易”或“消息调用”，它们不会在区块链上单独记录，但它们会影响状态并可能导致其他合约的执行。整个交易的状态变更会在确认后一起提交到区块链上。

# 调用函数并转帐如何实现
  - `feed.info{value: 10, gas: 800}(2);`
  - 注意 `feed.info{value: 10, gas: 800}` 仅（局部地）设置了与函数调用一起发送的 Wei 值和 gas 的数量，只有最后的小括号才执行了真正的调用。 因此， `feed.info{value: 10, gas: 800}` 是没有调用函数的， `value` 和 `gas` 设置是无效的。
# 解答
contract Feed {
    event DataReceived(uint256 data, address sender, uint256 amount);

    function info(uint256 data) external payable {
        require(msg.value > 0, "Ether value must be greater than 0");
        
        emit DataReceived(data, msg.sender, msg.value);
        // 这里可以处理接收到的 Ether 和 data 参数
    }
}
contract Example {
    Feed feed; // Feed 合约的实例

    constructor(address feedAddress) {
        feed = Feed(feedAddress); // 初始化 feed 实例
    }

    function callInfo() external payable {
        require(msg.value == 10 wei, "Must send exactly 10 Wei");
        
        // 调用 info 函数，发送 Ether
        feed.info{value: msg.value}(2); // 传递 10 Wei 和参数 2
    }
}

# extcodesize 操作码会检查要调用的合约是否确实存在，有哪些特殊情况？
  - 低级 call 调用，会绕过检查
  - 预编译合约的时候，也会绕过检查。
# 解答：
1、低级 call 调用: 使用低级 call 调用时，你可以直接与合约交互，而不进行 extcodesize 的检查。这意味着即使目标地址没有合约代码，调用依然可以执行，而不会阻止交易。
contract Example {
    function callExternal(address _addr, bytes memory _data) external {
        (bool success, ) = _addr.call(_data);
        require(success, "Call failed");
    }
}
在上述示例中，如果 _addr 指向一个非合约地址或没有代码的地址，call 调用仍然会被执行，而不会因 extcodesize 返回 0 而失败。
2、预编译合约:预编译合约（如某些地址上已实现的特定功能）可以绕过 extcodesize 检查，因为它们在特定地址上存在且被直接调用。这些地址可能并没有相应的 Solidity 合约代码，但仍能响应调用。

# 与其他合约交互时候有什么需要注意的？
  - 任何与其他合约的交互都会产生潜在危险，尤其是在不能预先知道合约代码的情况下。
  - 小心这个交互调用在返回之前再回调我们的合约，这意味着被调用合约可以通过它自己的函数改变调用合约的状态变量。 一个建议的函数写法是，例如，**在合约中状态变量进行各种变化后再调用外部函数**，这样，你的合约就不会轻易被滥用的重入攻击 (reentrancy) 所影响
# 解答：
1. 重入攻击（Reentrancy）
问题: 在调用外部合约时，如果该合约在执行过程中可以再次调用原合约，这可能导致重入攻击，修改状态变量的不安全性。
解决方案:
使用状态变量锁定: 在调用外部合约之前，先更改状态变量，确保不会被重入。
采用“检查-效果-交互”模式: 在执行状态变更（检查）后，进行外部调用（交互）
function withdraw(uint256 amount) external {
    require(balance[msg.sender] >= amount, "Insufficient balance");

    // 更新状态
    balance[msg.sender] -= amount;

    // 调用外部合约
    (bool success, ) = msg.sender.call{value: amount}("");
    require(success, "Transfer failed");
}


# public 既可以被当作内部函数也可以被当作外部函数。使用时候有什么注意的？
  - 如果想将一个函数当作内部函数使用，就用 `f` 调用，如果想将其当作外部函数，使用 `this.f` 。
# 解答：
1. 调用方式
function internalFunction() public {
    // 内部逻辑
}

function caller() public {
    internalFunction(); // 内部调用
}
function caller() public {
    this.externalFunction(); // 外部调用
}
2. Gas 成本
注意: 外部调用会增加 gas 消耗，尤其是在复杂操作中。应根据需要选择调用方式，以优化合约的执行效率。

# pure 函数中，哪些行为被视为读取状态。
  - 读取状态变量。
    - 这也意味着读取 `immutable` 变量也不是一个 `pure` 操作。
  - 访问 `address(this).balance` 或 `<address>.balance`
  - 访问 `block`，`tx`， `msg` 中任意成员 （除 `msg.sig` 和 `msg.data` 之外）。
  - 调用任何未标记为 `pure` 的函数。
  - **使用包含特定操作码的内联汇编。**
    - `TODO:` 这个不了解，需要用例子加深印象。
  - 使用操作码 `STATICCALL` , 这并不保证状态未被读取, 但至少不被修改。
# 解答：
1. 读取状态变量
描述: 访问合约的状态变量，包括 immutable 变量，会导致函数无法被标记为 pure。
uint256 public stateVariable;
uint256 immutable immutableVariable;
function setStateVariable(uint256 _value) public {
    stateVariable = _value;
}
function pureFunction() public view returns (uint256) {
    return stateVariable; // 这不是一个 pure 函数
}
2. 访问 address(this).balance 或 <address>.balance
描述: 访问合约或外部地址的余额也被视为读取状态。
function checkBalance() public view returns (uint256) {
    return address(this).balance; // 这不是一个 pure 函数
}
3. 访问 block、tx、msg 的成员
描述: 这些全局变量的任何成员访问都会导致函数无法被标记为 pure，除了 msg.sig 和 msg.data。
function getBlockNumber() public view returns (uint256) {
    return block.number; // 这不是一个 pure 函数
}
4. 调用未标记为 pure 的函数
描述: 调用任何未标记为 pure 的函数会使当前函数无法为 pure。
function nonPureFunction() public view returns (uint256) {
    return stateVariable; // 不是 pure
}
function anotherFunction() public pure {
    nonPureFunction(); // 这不是一个 pure 函数
}
5. 使用包含特定操作码的内联汇编
某些操作码的使用会被视为读取状态。这里的操作码包括 sload，它用于从存储中读取值。使用内联汇编进行 sload 会导致当前函数无法标记为 pure
function inlineAssemblyExample() public pure {
    assembly {
        let value := sload(0) // 读取状态变量，导致此函数不是 pure
    }
}
6. 使用 STATICCALL 操作码
描述: 使用 STATICCALL 来调用其他合约，可以保证不修改状态，但并不保证未读取状态。
function callAnotherContract(address target) public returns (uint256) {
    (bool success, bytes memory data) = target.staticcall(abi.encodeWithSignature("someFunction()"));
    require(success, "Call failed");
    return abi.decode(data, (uint256));
}


# pure 函数发生错误时候，有什么需要注意的？
  - 如果发生错误，`pure` 函数可以使用 `revert()` 和 `require()` 函数来还原潜在的状态更改。还原状态更改不被视为 **状态修改**, 因为它只还原以前在没有 `view` 或 `pure` 限制的代码中所做的状态更改, 并且代码可以选择捕获 revert 并不传递还原。这种行为也符合 STATICCALL 操作码。
# 解答:
1. 使用 revert() 和 require()
描述: pure 函数可以通过 revert() 和 require() 函数来处理错误。这些函数可以用来终止执行并还原状态。
function pureFunction(uint256 value) public pure {
    require(value > 0, "Value must be greater than zero");
    // 其他逻辑
}
2. 状态还原
描述: 调用 revert() 或 require() 不会修改合约的状态。它只是终止函数执行，并还原到函数调用之前的状态。
行为: 这种状态还原只适用于在没有 view 或 pure 限制的代码中所做的状态更改。
3. 与 STATICCALL 的一致性
描述: revert() 和 require() 的行为与 STATICCALL 操作码相符。在使用 STATICCALL 时，即使发生错误，状态也不会被修改，这确保了调用的安全性。
4. 捕获和处理错误
描述: 可以在调用 pure 函数时捕获错误并处理，但要注意，如果不处理 revert() 造成的错误，调用将终止并返回错误信息。
function caller() public {
    try this.pureFunction(0) {
        // 成功逻辑
    } catch {
        // 错误处理逻辑
    }
}
5. 关注 gas 消耗
描述: 即使是 pure 函数，在发生错误时也会消耗一定的 gas。因此，建议在编写逻辑时小心设计以避免不必要的 gas 消耗。

# view 函数中，哪些行为视为修改状态。
  - 修改状态变量。
  - 触发事件。
  - 创建其它合约。
  - 使用 `selfdestruct`。
  - 通过调用发送以太币。
  - 调用任何没有标记为 view 或者 pure 的函数。
  - 使用底层调用
    - (TODO:这里是 call 操作么？)
  - 使用包含某些操作码的内联程序集。

# pure/view/payable/这些状态可变性的类型转换是怎么样的？

  - pure 函数可以转换为 view 和 non-payable 函数
  - view 函数可以转换为 non-payable 函数
  - payable 函数可以转换为 non-payable 函数
  - 其他的转换则不可以。

# 使用 return 时，有哪些需要注意的？
  - 函数返回类型不能为空 —— 如果函数类型不需要返回，则需要删除整个 `returns (<return types>)` 部分。
  - 函数可能返回任意数量的参数作为输出。函数的返回值有两个关键字，一个是 `returns`,一个是 `return`;
    - `returns` 是在函数名后面的，用来标示返回值的数量，类型，名字信息。
    - `return` 是在函数主体内，用于返回 `returns` 指定的数据信息
  - 如果使用 return 提前退出有返回值的函数， 必须在用 return 时提供返回值。
  - 非内部函数有些类型没法返回，比如限制的类型有：多维动态数组、结构体等。
  - 解构赋值一个函数返回多值时候，元素数量必须一样。
# 解答：
1. 修改状态变量
描述: 任何对状态变量的写操作都将视为状态修改。
function modifyState() public view {
    stateVariable = 10; // 这不是一个 view 函数
}
2. 触发事件
描述: 发出事件也会修改状态，因此触发事件的函数不能被标记为 view。
event ExampleEvent(uint256 indexed value);
function triggerEvent() public view {
    emit ExampleEvent(1); // 这不是一个 view 函数
}
3. 创建其它合约
描述: 部署新的合约会改变区块链状态，因此这种操作不允许在 view 函数中进行。
function createContract() public view {
    new SomeContract(); // 这不是一个 view 函数
}
4. 使用 selfdestruct
描述: 调用 selfdestruct 会删除合约并改变状态，因此不能在 view 函数中使用。
function kill() public view {
    selfdestruct(payable(msg.sender)); // 这不是一个 view 函数
}
5. 通过调用发送以太币
描述: 发送以太币会改变合约状态，因此在 view 函数中不能执行。
function sendEther(address payable recipient) public view {
    recipient.transfer(1 ether); // 这不是一个 view 函数
}
6. 调用未标记为 view 或 pure 的函数
描述: 调用任何不符合 view 或 pure 限制的函数会导致状态修改。
function nonViewFunction() public {
    // 做一些状态修改
}
function callNonView() public view {
    nonViewFunction(); // 这不是一个 view 函数
}
7. 使用底层调用
描述: 使用低级调用（如 call）可能会导致状态修改，因此不能在 view 函数中使用。
function lowLevelCall(address target) public view {
    (bool success, ) = target.call(abi.encodeWithSignature("someFunction()")); // 这不是一个 view 函数
}
8. 使用包含特定操作码的内联汇编
描述: 使用某些操作码（如 sstore）在内联汇编中会修改状态，因此不允许在 view 函数中出现。
function inlineAssemblyExample() public view {
    assembly {
        sstore(0, 1) // 这不是一个 view 函数
    }
}

# 函数的签名的逻辑是什么？为什么函数可以重载？ 
  - 核心: `bytes4(keccak256(bytes("transfer(address,uint256)")))`
  - 函数签名被定义为基础原型的规范表达，而基础原型是**函数名称加上由括号括起来的参数类型列表，参数类型间由一个逗号分隔开，且没有空格。**
# 解答：跟js的函数复用做比较来记忆
1. 函数签名的定义——函数签名由以下部分组成：
函数名称: 函数的名字。
参数类型列表: 所有参数的类型，按顺序列出，并用逗号分隔，且不能有空格。
2. 签名的计算
函数签名通过将函数名称和参数类型组合在一起，然后计算其哈希值（使用 keccak256），最后取前 4 个字节来生成唯一标识符。示例：
bytes4 signature = bytes4(keccak256("transfer(address,uint256)"));
3. 函数重载的逻辑
函数可以重载的原因在于：
参数类型和数量的不同: Solidity 允许定义多个同名函数，只要它们的参数类型或参数数量不同。例如：
function transfer(address to, uint256 amount) public;
function transfer(address to, uint256 amount, string memory note) public;
function transfer(address to) public;
这些函数的签名分别为：
transfer(address,uint256)
transfer(address,uint256,string)
transfer(address)
由于它们的参数列表不同，因此可以同时存在。
4. 函数重载的实际应用
简化接口: 函数重载使得合约的接口更加简洁和灵活，用户可以根据不同的输入调用同一个函数名。
增强可读性: 通过重载，同名函数可以根据不同的上下文执行不同的操作，增加代码的可读性和可维护性。

# 函数重载需要怎么样实现？
  - **这些相同函数名的函数，参数(参数类型或参数数量)必须不一样。**，因为只有这样才能签出来不同的函数选择器。
  - 如果两个外部可见函数仅区别于 Solidity 内的类型，而不是它们的外部类型则会导致错误。很难理解，需要看例子。
# 解答： 
1. 实现函数重载的基本原则
不同的参数类型或数量: 只有当函数的参数类型或参数数量不同，才能定义多个同名函数。这样可以生成不同的函数选择器（函数签名的前 4 个字节）。
2. 注意事项
外部可见性与内部类型: 如果两个外部可见的函数仅在 Solidity 内部类型上有所不同，而在外部类型上没有区别，将会导致编译错误。例如：
contract Example {
    // 函数签名: "transfer(address)"
    function transfer(address to) public {
        // 逻辑
    }

    // 函数签名: "transfer(uint160)" // 这里 uint160 是 address 的内部表示
    function transfer(uint160 to) public {
        // 逻辑
    }
}
这里的第二个函数虽然类型不同，但在外部调用时都是地址，因此编译器会报错。解决方法是确保外部类型完全不同，或者使用不同的参数。
3. 示例代码
下面是一个完整的示例，展示如何正确实现函数重载：
contract Token {
    // 函数签名: "transfer(address,uint256)"
    function transfer(address to, uint256 amount) public {
        // 逻辑
    }

    // 函数签名: "transfer(address)"
    function transfer(address to) public {
        // 逻辑
    }

    // 函数签名: "transfer(address,uint256,string)"
    function transfer(address to, uint256 amount, string memory note) public {
        // 逻辑
    }
}

# 函数重载的参数匹配原理
  - 通过将当前范围内的函数声明与函数调用中提供的参数相匹配，这样就可以选择重载函数。
  - 如果所有参数都可以隐式地转换为预期类型，则该函数作为重载候选项。如果一个匹配的都没有，解析失败。
  - 返回参数不作为重载解析的依据。
# 解答：
1. 参数匹配原理
匹配过程: 当调用一个函数时，编译器会将函数调用中的参数与当前范围内的函数声明进行匹配。它会尝试找到一个合适的重载版本来处理传入的参数。
2. 隐式转换
隐式转换: 如果提供的参数可以隐式转换为函数预期的参数类型，则该函数被视为重载候选。例如：
function example(uint256 x) public {}
example(5); // 这里 5 是 uint 类型，可以隐式转换为 uint256
匹配候选项: 如果所有参数都能找到合适的匹配，编译器会选择该函数。如果没有一个函数能够匹配，则解析失败并抛出错误。
3. 没有匹配的情况
解析失败: 如果提供的参数无法与任何重载候选项匹配，编译器会给出错误信息，提示没有找到匹配的函数。
4. 返回参数不参与重载解析
重要说明: 函数的返回类型不参与重载解析
5. 示例代码
以下是一个示例，展示参数匹配的不同情况：
contract Example {
    // 重载函数
    function process(uint256 x) public {}
    function process(uint8 x) public {}
    function process(address x) public {}

    function callFunctions() public {
        process(5); // 调用 process(uint8)
        process(10); // 调用 process(uint256)

        // 下面的调用会失败
        // process("string"); // 错误: 找不到匹配的函数
    }
}

# ` function f(uint8 val) public pure returns (uint8 out)` 和 `function f(uint256 val) public pure returns (uint256 out)` 是合法的函数重载么？
# 解答： - 不是的。
  - 在 Remix 里,部署 A 合约，会将两个方法都渲染出来，调用 `f(50)`/`f(256)` 都可以。
  - 但是实际调用里，在其他合约内调用 `f(50)` 会导致类型错误，因为 `50` 既可以被隐式转换为 `uint8` 也可以被隐式转换为 `uint256`。 另一方面，调用 `f(256)` 则会解析为 `f(uint256)` 重载，因为 `256` 不能隐式转换为 `uint8`。

# 函数修改器的意义是什么？有什么作用？
  - **意义**:我们可以将一些通用的操作提取出来，包装为函数修改器，来提高代码的复用性，改善编码效率。是函数高内聚，低耦合的延伸。
  - **作用**: `modifier` 常用于在函数执行前检查某种前置条件。
  - 比如地址对不对，余额是否充足，参数值是否允许等
  - 修改器内可以写逻辑
  - **特点**: `modifier` 是一种合约属性，可被继承，同时还可被派生的合约重写(override)。（修改器 modifier 是合约的可继承属性，并可能被派生合约覆盖 , 但前提是它们被标记为 virtual）。
  - `_` 符号可以在修改器中出现多次，每处都会替换为函数体。
# 解答：
1. 意义
提高代码复用性: 修改器允许将通用的逻辑提取出来，封装成可重用的组件。这有助于减少代码重复，提高代码的整洁性和可维护性。
增强代码结构: 修改器实现了函数的高内聚和低耦合，使得逻辑清晰、职责明确。
2. 作用
前置条件检查: 修改器通常用于在函数执行前进行某些条件检查，例如：
检查调用者的地址是否有效。
验证余额是否充足。
确保传入参数符合预期。
逻辑处理: 修改器可以包含任何必要的逻辑，不仅限于条件检查，可以用于修改状态或执行其他操作。
3. 特点
合约属性: 修改器是合约的一种属性，可以被继承，使得子合约能够重用父合约中的修改器。
可重写: 如果将修改器标记为 virtual，子合约可以覆盖（override）该修改器，以提供特定的实现。
多次使用 _: 修改器中的 _ 符号可以出现多次，每次都会被替换为修饰的函数体。例如：
modifier onlyOwner() {
    require(msg.sender == owner, "Not the owner");
    _; // 这里是函数体的开始
}
modifier checkBalance(uint256 amount) {
    require(balance[msg.sender] >= amount, "Insufficient balance");
    _; // 这里是函数体的开始
}
function withdraw(uint256 amount) public onlyOwner checkBalance(amount) {
    balance[msg.sender] -= amount; // 函数体
    payable(msg.sender).transfer(amount); // 函数体
}
4. 示例代码
下面是一个示例，展示如何使用修改器进行条件检查：
contract Example {
    address public owner;
    mapping(address => uint256) public balance;

    constructor() {
        owner = msg.sender; // 合约创建者为所有者
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Not the owner");
        _; // 函数体在这里执行
    }

    modifier hasSufficientBalance(uint256 amount) {
        require(balance[msg.sender] >= amount, "Insufficient balance");
        _; // 函数体在这里执行
    }

    function deposit() public payable {
        balance[msg.sender] += msg.value; // 存款
    }

    function withdraw(uint256 amount) public onlyOwner hasSufficientBalance(amount) {
        // 只有合约拥有者才能调用的逻辑
        balance[msg.sender] -= amount; // 提款
        payable(msg.sender).transfer(amount); // 发送以太币
    }
}

# Solidity 有哪些全局的数学和密码学函数？
# 解答：
1. 数学函数：
  - `addmod(uint x, uint y, uint k) returns (uint)`
    - 计算 `(x + y) % k`，加法会在任意精度下执行，并且加法的结果即使超过 `2**256` 也不会被截取。从 0.5.0 版本的编译器开始会加入对 `k != 0` 的校验（assert）。
  - `mulmod(uint x, uint y, uint k) returns (uint)`
    - 计算 `(x * y) % k`，乘法会在任意精度下执行，并且乘法的结果即使超过 `2**256` 也不会被截取。从 0.5.0 版本的编译器开始会加入对 `k != 0` 的校验（assert）。
2. 密码学函数：
  - `keccak256((bytes memory) returns (bytes32)`
    - 计算 Keccak-256 哈希，之前 keccak256 的别名函数 **sha3** 在 **0.5.0** 中已经移除。。
  - `sha256(bytes memory) returns (bytes32)`
    - 计算参数的 SHA-256 哈希。
  - `ripemd160(bytes memory) returns (bytes20)`
    - 计算参数的 RIPEMD-160 哈希。
  - `ecrecover(bytes32 hash, uint8 v, bytes32 r, bytes32 s) returns (address)`
    - 利用椭圆曲线签名恢复与公钥相关的地址，错误返回零值。
    - 函数参数对应于 ECDSA 签名的值:
      - r = 签名的前 32 字节
      - s = 签名的第 2 个 32 字节
      - v = 签名的最后一个字节
    - ecrecover 返回一个 address, 而不是 address payable。
   address payable地址表示可以转账以太坊。 