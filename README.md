```bash
# 在指定网络上验证合约
npx hardhat verify --network mumbai 0xf570916e61Cf39d46e09552B048937aCA469AE8B
npx hardhat verify --network rinkeby --constructor-args arguments.js 0xeba54d8b4fad9e898272d8da79ee3f19657dc606
npx hardhat verify --network rinkeby --constructor-args arguments.js 0x69dd4dbe1e3D576e366587B3573Fba76dD3eF33C
```

```bash
# 生成在版本管理的文件树
git ls-files | tree -I 'node_modules' --fromfile
```

```
├── .gitattributes
├── .gitignore
├── .vscode
│   └── settings.json
├── LICENSE
├── README.md
├── arguments.js // 参数
├── contracts
│   ├── ERC1155DynamicTradable.sol // ERC1155可修改元数据NFT合约
│   ├── ERC1155Tradable.sol // ERC1155 NFT合约
│   ├── ERC721DynamicTradable.sol // ERC721可修改元数据NFT合约
│   ├── ERC721Tradable.sol // ERC721 NFT合约
│   ├── Market.sol // 交易市场合约
│   ├── ProxyRegistry.sol // 代理合约
│   └── Tradable.sol // 基础交易合约
├── hardhat.config.ts
├── package-lock.json
├── package.json
├── scripts
│   ├── deploy.ts // 部署合约脚本
│   ├── deployNFT.ts // 部署NFT合约脚本
│   ├── deployProxy.ts // 部署代理合约脚本
│   ├── mint.ts // 铸造脚本
│   ├── trade.ts // 测试交易脚本
│   └── verify.ts // 验证合约脚本
├── test // 单元测试
│   ├── local
│   │   ├── 721.ts
│   │   ├── test copy.ts
│   │   └── test.ts
│   └── online.ts
└── tsconfig.json
```
