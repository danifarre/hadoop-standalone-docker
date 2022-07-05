FROM ubuntu:20.04

RUN apt-get update \
    && apt-get install -y openjdk-8-jdk \
    && apt-get install -y ssh

ENV JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa \
    && cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys \
    && chmod 0600 ~/.ssh/authorized_keys

WORKDIR /apps

RUN wget https://archive.apache.org/dist/hadoop/common/hadoop-3.1.1/hadoop-3.1.1.tar.gz \
    && tar xzf hadoop-3.1.1.tar.gz \
    && rm hadoop-3.1.1.tar.gz

ENV HADOOP_HOME=/apps/hadoop-3.1.1

ENV HADOOP_COMMON_HOME=$HADOOP_HOME \
    HADOOP_HDFS_HOME=$HADOOP_HOME \
    HADOOP_MAPRED_HOME=$HADOOP_HOME \
    HADOOP_YARN_HOME=$HADOOP_HOME \
    HADOOP_OPTS="-Djava.library.path=$HADOOP_HOME/lib/native" \
    HADOOP_COMMON_LIB_NATIVE_DIR=$HADOOP_HOME/lib/native
    
ENV PATH=$PATH:$HADOOP_HOME/sbin:$HADOOP_HOME/bin

WORKDIR /apps/hadoop-3.1.1

COPY /conf/core-site.xml etc/hadoop/ 
COPY /conf/hdfs-site.xml etc/hadoop/

RUN echo export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 >> etc/hadoop/hadoop-env.sh \
    echo export HDFS_NAMENODE_USER=root >> etc/hadoop/hadoop-env.sh \
    echo export HDFS_DATANODE_USER=root >> etc/hadoop/hadoop-env.sh \
    echo export HDFS_SECONDARYNAMENODE_USER=root >> etc/hadoop/hadoop-env.sh \
    echo export YARN_RESOURCEMANAGER_USER=root >> etc/hadoop/hadoop-env.sh \
    echo export YARN_NODEMANAGER_USER=root >> etc/hadoop/hadoop-env.sh

RUN hdfs namenode -format

EXPOSE 9870

ADD start.sh /
RUN chmod +x /start.sh

CMD ["/start.sh"]
