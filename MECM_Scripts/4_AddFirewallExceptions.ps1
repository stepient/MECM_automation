param(

)

$Rules = @(
                @{
                    DisplayName = "SQL Server"
                    Direction = "Inbound"
                    Action = "Allow"
                    Protocol = "TCP"
                    LocalPort = 1433
                }

                @{
                    DisplayName = "SQL Admin Connection"
                    Direction = "Inbound"
                    Action = "Allow"
                    Protocol = "TCP"
                    LocalPort = 1434
                }

                @{
                    DisplayName = "SQL Service Broker"
                    Direction = "Inbound"
                    Action = "Allow"
                    Protocol = "TCP"
                    LocalPort = 4022
                }

                @{
                    DisplayName = "SQL Debugger/RPC"
                    Direction = "Inbound"
                    Action = "Allow"
                    Protocol = "TCP"
                    LocalPort = 135
                }

                @{
                    DisplayName = "Analysis Services"
                    Direction = "Inbound"
                    Action = "Allow"
                    Protocol = "TCP"
                    LocalPort = 2383
                }

                @{
                    DisplayName = "SQL Browser"
                    Direction = "Inbound"
                    Action = "Allow"
                    Protocol = "TCP"
                    LocalPort = 2382
                }

                @{
                    DisplayName = "HTTP"
                    Direction = "Inbound"
                    Action = "Allow"
                    Protocol = "TCP"
                    LocalPort = 80
                }

                @{
                    DisplayName = "SSL"
                    Direction = "Inbound"
                    Action = "Allow"
                    Protocol = "TCP"
                    LocalPort = 443
                }

                @{
                    DisplayName = "SQL Browser button"
                    Direction = "Inbound"
                    Action = "Allow"
                    Protocol = "TCP"
                    LocalPort = 1434
                }
    
                @{
                    DisplayName = "ICMP Allow incoming V4 echo request"
                    Direction = "Inbound"
                    Action = "Allow"
                    Protocol = "TCP"
                    LocalPort = 1434
                }

)

Foreach ($Rule in $Rules)
{
    $Rule
    New-NetFirewallRule @Rule
}

#@echo ========= SQL Server Ports ===================
#@echo Enabling SQLServer default instance port 1433
#netsh advfirewall firewall add rule name="SQL Server" dir=in action=allow protocol=TCP localport=1433
#@echo Enabling Dedicated Admin Connection port 1434
#netsh advfirewall firewall add rule name="SQL Admin Connection" dir=in action=allow protocol=TCP localport=1434
#@echo Enabling conventional SQL Server Service Broker port 4022
#netsh advfirewall firewall add rule name="SQL Service Broker" dir=in action=allow protocol=TCP localport=4022
#@echo Enabling Transact-SQL Debugger/RPC port 135
#netsh advfirewall firewall add rule name="SQL Debugger/RPC" dir=in action=allow protocol=TCP localport=135
#@echo ========= Analysis Services Ports ==============
#@echo Enabling SSAS Default Instance port 2383
#netsh advfirewall firewall add rule name="Analysis Services" dir=in action=allow protocol=TCP localport=2383
#@echo Enabling SQL Server Browser Service port 2382
#netsh advfirewall firewall add rule name="SQL Browser" dir=in action=allow protocol=TCP localport=2382
#@echo ========= Misc Applications ==============
#@echo Enabling HTTP port 80
#netsh advfirewall firewall add rule name="HTTP" dir=in action=allow protocol=TCP localport=80
#@echo Enabling SSL port 443
#netsh advfirewall firewall add rule name="SSL" dir=in action=allow protocol=TCP localport=443
#@echo Enabling port for SQL Server Browser Service's 'Browse' Button
#netsh advfirewall firewall add rule name="SQL Browser" dir=in action=allow protocol=TCP localport=1434
# Allowing Ping command
netsh advfirewall firewall add rule name="ICMP Allow incoming V4 echo request" protocol=icmpv4:8,any dir=in action=allow
