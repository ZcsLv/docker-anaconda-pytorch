FROM       nvidia/cuda:11.4.2-devel-ubuntu20.04	
# 教程参考:https://segmentfault.com/a/1190000007652344
# https://github.com/okwrtdsh/anaconda3
MAINTAINER caicandong <caicnadog@shu.edu.cn> 

ENV TZ=Asia/Shanghai\
    DEBIAN_FRONTEND=noninteractive \
    PATH=/opt/conda/bin:$PATH 
# 设置时区:上海
# RUN echo "Asia/Shanghai" > /etc/timezone;dpkg-reconfigure -f noninteractive tzdata

# 设置工作路径
WORKDIR /root

RUN apt-key adv --fetch-keys https://developer.download.nvidia.com/compute/cuda/repos/ubuntu1804/x86_64/3bf863cc.pub

# 更新软件包
RUN apt-get update 

# echo 'export PATH=/opt/conda/bin:$PATH' > /etc/profile.d/conda.sh

# 配置远程连接 ssh
RUN apt-get install -y openssh-server \ 
    && mkdir /var/run/sshd  && mkdir /root/.ssh \
    && echo 'root:root' |chpasswd \
    && sed -ri 's/^#?PermitRootLogin\s+.*/PermitRootLogin yes/' /etc/ssh/sshd_config  \
    && sed -ri 's/UsePAM yes/#UsePAM yes/g' /etc/ssh/sshd_config

# 下载Anaconda并安装
RUN wget -O /opt/Anaconda3-2021.05-Linux-x86_64.sh "https://repo.anaconda.com/archive/Anaconda3-2021.05-Linux-x86_64.sh" \
    && chmod +x /opt/Anaconda3-2021.05-Linux-x86_64.sh \
    && sh -c '/bin/echo -e "\nyes\n\nyes" | sh /opt/Anaconda3-2021.05-Linux-x86_64.sh -b -p /opt/conda' 

# 调整时区
RUN apt install -y tzdata \
    && ln -fs /usr/share/zoneinfo/${TZ} /etc/localtime \
    && echo ${TZ} > /etc/timezone \
    && dpkg-reconfigure --frontend noninteractive tzdata 

# 虚拟环境+pytorch
# Make RUN commands use the new environment:(ref:https://pythonspeed.com/articles/activate-conda-dockerfile/#working)
# 创建虚拟环境并激活 
RUN conda create --name py37  python=3.7 
SHELL ["conda", "run", "-n", "py37", "/bin/bash", "-c"]
# 安装pytorch
RUN conda install -y --quiet numpy pyyaml mkl mkl-include setuptools cmake cffi typing \
 && conda install -y --quiet -c mingfeima mkldnn \
 && conda install -y --quiet pytorch torchvision torchaudio cudatoolkit=11.3 -c pytorch


RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
    
EXPOSE 22
# 指定脚本的运行
CMD ["bash"]