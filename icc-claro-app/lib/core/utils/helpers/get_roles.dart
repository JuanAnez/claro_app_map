import 'dart:convert';

List<String> getRolesFromAuthorities(dynamic authorities) {
    print("🔍 getRolesFromAuthorities DEBUG - INICIO");
    print("  Input: '$authorities' (tipo: ${authorities.runtimeType})");
    
    if (authorities is String) {
      print("  Es String, procesando...");
      
      // Primero intentar parsear como JSON (caso más común)
      try {
        final decoded = jsonDecode(authorities);
        print("  JSON decodificado: $decoded");
        
        if (decoded is Map) {
          // Caso 1: {"message": "POS_USER"}
          if (decoded.containsKey('message')) {
            final message = decoded['message'];
            print("  Message encontrado: '$message'");
            if (message is String) {
              if (message.contains(',')) {
                final roles = message.split(',').map((role) => role.trim()).toList();
                print("  Roles del message (con comas): $roles");
                return roles;
              } else {
                final roles = [message.trim()];
                print("  Roles del message (sin comas): $roles");
                return roles;
              }
            }
          }
          
          // Caso 2: {"authorities": ["POS_USER"]}
          if (decoded.containsKey('authorities') && decoded['authorities'] is List) {
            final authoritiesList = decoded['authorities'] as List;
            final roles = authoritiesList.map((role) => role.toString().trim()).toList();
            print("  Roles del campo authorities: $roles");
            return roles;
          }
        }
      } catch (jsonError) {
        print("  No es JSON válido: $jsonError");
        print("  Continuando con string directo...");
      }
      
      // Caso: string directo como "POS_USER" o "POS_USER,POS_ADMIN"
      print("  Procesando como string directo: '$authorities'");
      if (authorities.contains(',')) {
        final roles = authorities.split(',').map((role) => role.trim()).toList();
        print("  Roles extraídos (con comas): $roles");
        return roles;
      } else {
        final roles = [authorities.trim()];
        print("  Roles extraídos (sin comas): $roles");
        return roles;
      }
    } else {
      print("  No es String, es: ${authorities.runtimeType}");
    }
    
    print("  Retornando lista vacía");
    print("🔍 getRolesFromAuthorities DEBUG - FIN");
    return [];
  }