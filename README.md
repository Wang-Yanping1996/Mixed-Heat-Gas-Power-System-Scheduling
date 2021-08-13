# Mixed-Heat-Gas-Power-System-Scheduling  
热网，气网，电网简单混合系统的调度

数据来源和模型说明见“模型与数据”文件夹下的word和excel（林玲整理），参考文献在文件“模型与数据.docx”中以批注标示。
the instructions of data and model are in the word and excel under "model and data" file (collected by Lin Ling). References are marked with comments in the file "模型与数据.docx".

直接运行"HeatGasPowerCombination.m"  
run "HeatGasPowerCombination.m" directly

Besides, note that the model is based on the Matlab, Yalmip, and the solver is Gurobi. It can be changed to other solvers, such as Cplex, by modifying the parameter 'gurobi' in sentence 'ops = settings('solver','gurobi'.   
此外，请注意，该模型基于Matlab，Yalmip，求解器为Gurobi。 通过修改句子'ops = settings('solver'，'gurobi'中的参数'gurobi'，可以将其更改为其他求解器，例如Cplex。  If you have any idea on improving this model, please contact me. 如果您有任何改进此模型的想法，请联系我.

本项目只用于交流，希望不要出现商业行为（之前在闲鱼上竟然发现有人转卖），谢谢！  
This project is used for communication, not for commercial purposes(Before, I found someone reselling this project on the Xianyu), thanks!

注：matlab上传github，中文注释乱码的问题，暂时没找到解决办法，如果您有，可以告诉我。目前我的解决方法是，上传了一个.zip的压缩包，下载后解压应该不会乱码。
Note that: when I upload the .m files to github, its Chinese notes will be error codes, I didn't find any way to solve it, if you know, please tell me. Now my solution is that a .zip file is uploaded, upzip it seems to avoid the error codes problem.

基于matlab及yalmip的混合系统调度模型  
王砚平  
2020.04  
