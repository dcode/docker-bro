# Install Bro Required Dependencies
FROM centos:6.6

# Install EPEL
RUN yum install -y https://dl.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm 

# Update packages and install runtime and build deps for bro
RUN yum -y -q upgrade 
RUN yum -y -q install libpcap openssl bind-libs zlib bash python libcurl gawk GeoIP gperftools 
RUN yum -y -q install @development libpcap-devel openssl-devel bind-devel zlib-devel git perl libcurl-devel GeoIP-devel gperftools-devel swig python-devel \
  https://copr-be.cloud.fedoraproject.org/results/dcode/EL6_Useful/epel-6-x86_64/cmake-2.8.8-1.rfx/cmake-2.8.8-1.el6.x86_64.rpm

# Build bro
RUN git clone git://git.bro.org/bro /opt/thirdparty/bro 

WORKDIR /opt/thirdparty/bro
RUN git checkout v2.4
RUN git submodule update --init --recursive
RUN ./configure --prefix=/opt/bro 
RUN make
RUN make install

# Cleanup disk
RUN yum -y clean all

# Add GeoIPLite databases
ADD /geoip /usr/share/GeoIP/
RUN \
 gunzip -f /usr/share/GeoIP/GeoLiteCityv6.dat.gz && \
 gunzip -f /usr/share/GeoIP/GeoLiteCity.dat.gz && \
 rm -f /usr/share/GeoIP/GeoLiteCityv6.dat.gz && \
 rm -f /usr/share/GeoIP/GeoLiteCity.dat.gz && \
 ln -f -s /usr/share/GeoIP/GeoLiteCityv6.dat /usr/share/GeoIP/GeoIPCityv6.dat && \
 ln -f -s /usr/share/GeoIP/GeoLiteCity.dat /usr/share/GeoIP/GeoIPCity.dat

ENV PATH /opt/bro/bin:$PATH

# Add PCAP test folder
ADD /pcap /data/pcap
VOLUME ["/data/pcap"]
WORKDIR /data/pcap

# Add scripts folder
ADD /scripts /opt/share/bro/site/scripts
ADD /scripts/local.bro /opt/bro/share/bro/site/local.bro

ENTRYPOINT ["bro"]

CMD ["-h"]

