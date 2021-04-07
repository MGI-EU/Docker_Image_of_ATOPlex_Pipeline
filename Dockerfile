#  Ubuntu 18.04 as base image
FROM ubuntu:18.04

RUN echo "bash;" >> /docker-entrypoint.sh
ENTRYPOINT ["sh", "/docker-entrypoint.sh"]
ENV HOME /root
WORKDIR /root
EXPOSE 80
EXPOSE 22
EXPOSE 443
# Copy the Dockerfile to root for reference
ADD Dockerfile /root/.Dockerfile

# Update
RUN apt-get update
RUN apt-get install -qy apt-utils vim openjdk-8-jdk

# CPAN packages
RUN apt-get install -qy cpanminus
RUN cpanm Term::ReadLine

# Install Packages
RUN apt-get install -qy software-properties-common build-essential
RUN apt-get install -qy nano wget less screen rsync git
RUN apt-get install -qy zlib1g-dev libbz2-dev liblzma-dev

# Configure Timezone
RUN echo 'Europe/Stockholm' > /etc/timezone
RUN export DEBIAN_FRONTEND=noninteractive && apt-get install -qy tzdata

# Install R-package
RUN apt-get -qy install r-base libxt-dev libcairo2-dev
RUN Rscript -e 'install.packages("Cairo")'

# Install python3.4
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt-get install -qy python3.4 python3-pip python-dev libpython3.4-dev
RUN ln -sf /usr/bin/python3.4 /usr/bin/python3

# Install Python module
RUN pip3 install cython
RUN pip3 install pysam
RUN pip3 install pandas==0.19
RUN pip3 install openpyxl

# Install SARS-CoV-2 code base
RUN mkdir /root/repos
RUN cd /root/repos && git clone https://github.com/MGI-tech-bioinformatics/SARS-CoV-2_Multi-PCR_v1.0;

# htslib (tabix bgzip)
RUN apt-get install -qy libcurl4-openssl-dev
RUN cd /root/repos && git clone https://github.com/samtools/htslib.git
RUN cd /root/repos/htslib && autoheader && autoconf && ./configure && make && make install
RUN cp /root/repos/htslib/bgzip /root/repos/SARS-CoV-2_Multi-PCR_v1.0/tools/.
RUN cp /root/repos/htslib/tabix /root/repos/SARS-CoV-2_Multi-PCR_v1.0/tools/.

# bcftools
RUN cd /root/repos/ && wget https://github.com/samtools/bcftools/releases/download/1.6/bcftools-1.6.tar.bz2
RUN cd /root/repos/ && tar -xvf bcftools-1.6.tar.bz2
RUN cd /root/repos/bcftools-1.6 && ./configure && make
RUN cp /root/repos/bcftools-1.6/bcftools /root/repos/SARS-CoV-2_Multi-PCR_v1.0/tools/.

#seqtk
RUN cd /root/repos/ && \
git clone https://github.com/lh3/seqtk.git && \
cd seqtk/ && \
make

#SOAPnuke
RUN cd /root/repos/ && \
wget https://github.com/BGI-flexlab/SOAPnuke/archive/1.5.6-linux.zip && \
unzip 1.5.6-linux.zip

#bamdst
RUN cd /root/repos/ && \
git clone https://github.com/shiquan/bamdst.git && \
cd bamdst/ && \
make

# Terminal
RUN echo 'export PATH=$PATH:/root/repos/SARS-CoV-2_Multi-PCR_v1.0/bin' >> /root/.bashrc
RUN PS1="[\u@\h:\W]\$ ";

# CleanUp
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*;

CMD ["bash"]
