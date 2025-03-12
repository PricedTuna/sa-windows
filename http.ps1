<#  
    Script: Instalador de servicios HTTP para Windows y Linux  
    Objetivo: Permitir, desde un cliente SSH, la instalación silenciosa de servicios HTTP.  
    Características:  
      - Funciones modulares.  
      - Validación de entradas de usuario.  
      - Opción en Linux para elegir entre Apache, Tomcat o Nginx, mostrando versiones LTS y de desarrollo.  
      - En Windows se instala IIS obligatoriamente y se ofrecen dos servicios adicionales opcionales.  
      
    Nota: Los comandos de instalación son simulados.  
    ¡Recuerda que "menos es más", y la validación de entradas es clave para evitar vulnerabilidades!  
    (Basado en estudios de validación de entradas y mejores prácticas de PowerShell – ver referencias al final).  
#>

# Función para simular la instalación silenciosa en Linux
function Install-LinuxService {
    param(
        [string]$Service,
        [string]$Version,
        [int]$Port
    )
    Write-Output "Instalando $Service versión $Version en el puerto $Port en Linux..."
    # Aquí iría la ejecución real, por ejemplo:
    # sudo apt-get install $Service -y
    Start-Sleep -Seconds 2  # Simula tiempo de instalación
    Write-Output "$Service se ha instalado correctamente en Linux."
}

# Función para simular la instalación silenciosa en Windows
function Install-WindowsService {
    param(
        [string]$Service,
        [string]$Version,
        [int]$Port
    )
    Write-Output "Instalando $Service versión $Version en el puerto $Port en Windows..."
    # Aquí se podría descargar y ejecutar el instalador de forma silenciosa
    Start-Sleep -Seconds 2  # Simula tiempo de instalación
    Write-Output "$Service se ha instalado correctamente en Windows."
}

# Función para instalar IIS en Windows (instalación forzosa)
function Install-IIS {
    Write-Output "Instalando IIS (¡a lo obligatorio, colega!)..."
    # Comando real para instalar IIS en Windows Server:
    Install-WindowsFeature -Name Web-Server -IncludeManagementTools -ErrorAction Stop
    Write-Output "IIS instalado correctamente."
}

# Función para obtener las versiones disponibles según el servicio seleccionado
function Get-ServiceVersion {
    param(
        [string]$Service
    )
    switch ($Service) {
        "Apache" {
            $lts = "2.4.58"
            $dev = "2.4.1"
        }
        "Tomcat" {
            $lts = "9.0.65"
            $dev = "10.1.0"
        }
        "Nginx" {
            $lts = "1.22.1"
            $dev = "1.23.0"
        }
        default {
            Write-Output "Servicio no reconocido."
            return $null
        }
    }
    return @{ "LTS" = $lts; "DEV" = $dev }
}

# Función para validar que el puerto ingresado es numérico y está en el rango correcto
function Validate-Port {
    param(
        [string]$PortInput
    )
    if ([int]::TryParse($PortInput, [ref]$null)) {
        $port = [int]$PortInput
        if ($port -ge 1 -and $port -le 65535) {
            return $port
        }
    }
    return $null
}

# Función para solicitar y validar el puerto
function Prompt-ForPort {
    while ($true) {
        $portInput = Read-Host "Ingrese el puerto para la configuración (1-65535)"
        $port = Validate-Port -PortInput $portInput
        if ($port -ne $null) {
            return $port
        } else {
            Write-Output "Puerto inválido. ¡Vamos, no seas mojigato, inténtalo de nuevo!"
        }
    }
}

# Función para solicitar el servicio a instalar en Linux
function Prompt-ForServiceSelection-Linux {
    Write-Output "Seleccione el servicio HTTP a instalar en Linux:"
    Write-Output "1. Apache"
    Write-Output "2. Tomcat"
    Write-Output "3. Nginx"
    while ($true) {
        $selection = Read-Host "Ingrese el número de la opción"
        if ($selection -in "1","2","3") {
            switch ($selection) {
                "1" { return "Apache" }
                "2" { return "Tomcat" }
                "3" { return "Nginx" }
            }
        } else {
            Write-Output "Selección inválida, por favor, inténtalo de nuevo."
        }
    }
}

# Función para solicitar el servicio adicional a instalar en Windows
function Prompt-ForServiceSelection-Windows {
    Write-Output "IIS se instalará de manera obligatoria en Windows."
    Write-Output "Opcionalmente, puede instalar un servicio adicional."
    Write-Output "Seleccione una opción:"
    Write-Output "0. No instalar servicios adicionales"
    Write-Output "1. Apache"
    Write-Output "2. Tomcat"
    while ($true) {
        $selection = Read-Host "Ingrese el número de la opción"
        if ($selection -in "0","1","2") {
            switch ($selection) {
                "0" { return $null }
                "1" { return "Apache" }
                "2" { return "Tomcat" }
            }
        } else {
            Write-Output "Selección inválida, prueba otra vez."
        }
    }
}

# Función para solicitar la versión a instalar, mostrando las dos opciones disponibles
function Prompt-ForVersion {
    param(
        [string]$Service
    )
    $versions = Get-ServiceVersion -Service $Service
    if ($versions -eq $null) { return $null }
    Write-Output "Versiones disponibles para $Service:"
    Write-Output "1. LTS: $($versions['LTS'])"
    Write-Output "2. Desarrollo: $($versions['DEV'])"
    while ($true) {
        $selection = Read-Host "Seleccione la versión (1 para LTS, 2 para Desarrollo)"
        if ($selection -eq "1") {
            return $versions["LTS"]
        } elseif ($selection -eq "2") {
            return $versions["DEV"]
        } else {
            Write-Output "Selección inválida, inténtalo de nuevo."
        }
    }
}

# Función principal que coordina el flujo del script
function Main {
    Write-Output "¡Bienvenido al instalador de servicios HTTP, colega! Vamos a darle caña."
    Write-Output "Seleccione el sistema operativo de destino:"
    Write-Output "1. Linux"
    Write-Output "2. Windows"
    while ($true) {
        $osSelection = Read-Host "Ingrese el número de la opción"
        if ($osSelection -eq "1") {
            # Instalación para Linux
            $service = Prompt-ForServiceSelection-Linux
            $version = Prompt-ForVersion -Service $service
            $port = Prompt-ForPort
            Install-LinuxService -Service $service -Version $version -Port $port
            break
        } elseif ($osSelection -eq "2") {
            # Instalación para Windows
            Install-IIS
            $service = Prompt-ForServiceSelection-Windows
            if ($service) {
                $version = Prompt-ForVersion -Service $service
                $port = Prompt-ForPort
                Install-WindowsService -Service $service -Version $version -Port $port
            } else {
                Write-Output "No se instalaron servicios adicionales. ¡IIS se lleva el protagonismo!"
            }
            break
        } else {
            Write-Output "Selección inválida, inténtalo de nuevo."
        }
    }
    Write-Output "Proceso de instalación completado. ¡A disfrutar, amigo!"
}

# Ejecutar la función principal
Main
