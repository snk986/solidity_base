# Sample Hardhat Project

This project demonstrates a basic Hardhat use case. It comes with a sample contract, a test for that contract, and a Hardhat Ignition module that deploys that contract.

Try running some of the following tasks:

```shell
npx hardhat help
npx hardhat test
REPORT_GAS=true npx hardhat test
npx hardhat node
npx hardhat ignition deploy ./ignition/modules/Lock.js

```
# 项目经验与报错解决方法  
1、nvm的node版本用最新的22.7.0；
2、npm设置官方源，使用最新淘宝源安装依赖、初始化项目可能失败，使用nrm来管理源分支
3、npx hardhat compile   Error HH1: You are not inside a Hardhat project. 报错是因为没有目录不对，没有进入Hardhat项目
# hardhat错误码： https://hardhat.org/hardhat-runner/docs/errors
4、出现Error HH5等错误时，HH505，用npx hardhat clean --global，然后重新执行，
继续出现HH501、HH502、HH503可能是网络原因，查看是否官方源，是就继续执行，还有一个重要原因是设置了DNS
5、如果是nvm、node、npm等原因，删除nvm和node，重新安装，记得环境变量和用户里的配置文件也删除干净

