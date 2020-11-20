package Classes::Stulz;
our @ISA = qw(Classes::Device);

# hardwareTypeControllerType 1.3.6.1.4.2.1.1.7
# 0=unknown, 1=C4000, 2=C1001,
# 3=C1002, 4=C5000, 5=C6000, 6=C1010,
# 7=C7000IOC, 8=C7000AT, 9=C7000PT,
# 10=C5MSC, 11=C7000PT2, 12=C2020,
# 13=C100, 14=C102, 15=C103

# Wib8000 is the web head
# it connects to a Stulz-Bus
# members of the bus are units (=controllers), type c5000, c1002
# units have modules
# in fact it's the modules which are wired with the bus

#
#         +--Unit1--+    +--Unit2--+   ...
#         | c5000   |    | c1002   |
#         +---------+    +---------+
#         | hi | lo |    | hi | lo |
#         +----+----+    +----+----+
#            |    |         |    |
#        ----+--------------+    |
#  wib            |              |
#        ---------+--------------+


