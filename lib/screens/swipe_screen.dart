import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import '../widgets/custom_widgets.dart';
import '../themes/app_theme.dart';
import '../utils/validators.dart';
import 'matches_screen.dart';
import 'login_screen.dart';

class SwipeScreen extends StatefulWidget {
  @override
  _SwipeScreenState createState() => _SwipeScreenState();
}

class _SwipeScreenState extends State<SwipeScreen> with TickerProviderStateMixin {
  final UserService _userService = UserService();
  List<User> _users = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  
  late AnimationController _cardController;
  late AnimationController _matchController;
  late Animation<double> _cardRotation;
  late Animation<Offset> _cardOffset;
  late Animation<double> _matchAnimation;
  
  bool _showMatchDialog = false;
  User? _matchedUser;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadUsers();
  }

  void _setupAnimations() {
    _cardController = AnimationController(
      duration: Duration(milliseconds: 300),
      vsync: this,
    );
    
    _matchController = AnimationController(
      duration: Duration(milliseconds: 800),
      vsync: this,
    );
    
    _cardRotation = Tween<double>(begin: 0, end: 0).animate(_cardController);
    _cardOffset = Tween<Offset>(begin: Offset.zero, end: Offset.zero).animate(_cardController);
    _matchAnimation = Tween<double>(begin: 0, end: 1).animate(_matchController);
  }

  @override
  void dispose() {
    _cardController.dispose();
    _matchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await _userService.getPotentialMatches();
      setState(() {
        _users = users;
        _currentIndex = 0;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      Utils.showSnackBar(context, 'Error al cargar usuarios', isError: true);
    }
  }

  void _onSwipe(bool isLike) async {
    if (_currentIndex >= _users.length) return;

    final user = _users[_currentIndex];
    
    // Animación de salida de la carta
    if (isLike) {
      _cardRotation = Tween<double>(begin: 0, end: 0.3).animate(_cardController);
      _cardOffset = Tween<Offset>(begin: Offset.zero, end: Offset(2, -0.5)).animate(_cardController);
    } else {
      _cardRotation = Tween<double>(begin: 0, end: -0.3).animate(_cardController);
      _cardOffset = Tween<Offset>(begin: Offset.zero, end: Offset(-2, -0.5)).animate(_cardController);
    }
    
    await _cardController.forward();
    
    // Procesar el swipe
    final isMatch = await _userService.processSwipe(user.id, isLike);
    
    if (isMatch && isLike) {
      _matchedUser = user;
      _showMatchDialog = true;
      _matchController.forward();
    }
    
    // Siguiente usuario
    setState(() {
      _currentIndex++;
    });
    
    _cardController.reset();
    
    if (_currentIndex >= _users.length) {
      _loadUsers(); // Cargar más usuarios
    }
  }

  void _closeMatchDialog() {
    setState(() {
      _showMatchDialog = false;
      _matchedUser = null;
    });
    _matchController.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.favorite, color: Colors.white),
            SizedBox(width: 8),
            Text('Descubre'),
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'logout') {
                _logout();
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, color: AppTheme.primaryColor),
                    SizedBox(width: 8),
                    Text('Cerrar sesión'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          // Contenido principal
          _isLoading ? _buildLoading() : _buildSwipeCards(),
          
          // Botones de acción
          if (!_isLoading && _users.isNotEmpty && _currentIndex < _users.length)
            _buildActionButtons(),
          
          // Diálogo de match
          if (_showMatchDialog) _buildMatchDialog(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.explore),
            label: 'Descubrir',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Matches',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => MatchesScreen()),
            );
          }
        },
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
          SizedBox(height: 16),
          Text(
            'Buscando personas cerca de ti...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeCards() {
    if (_users.isEmpty || _currentIndex >= _users.length) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.sentiment_satisfied,
              size: 80,
              color: AppTheme.textSecondary,
            ),
            SizedBox(height: 16),
            Text(
              'No hay más personas por ahora',
              style: TextStyle(
                fontSize: 18,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: 16),
            CustomButton(
              text: 'Buscar más',
              onPressed: _loadUsers,
              width: 200,
            ),
          ],
        ),
      );
    }

    return Center(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Stack(
          children: [
            // Cartas de fondo (próximas)
            for (int i = _currentIndex + 1; i < _currentIndex + 3 && i < _users.length; i++)
              Positioned.fill(
                child: Transform.scale(
                  scale: 0.9 - (i - _currentIndex - 1) * 0.05,
                  child: Transform.translate(
                    offset: Offset(0, (i - _currentIndex - 1) * 10.0),
                    child: UserCard(user: _users[i]),
                  ),
                ),
              ),
            
            // Carta actual (animada)
            AnimatedBuilder(
              animation: _cardController,
              builder: (context, child) {
                return Transform.translate(
                  offset: _cardOffset.value * MediaQuery.of(context).size.width,
                  child: Transform.rotate(
                    angle: _cardRotation.value,
                    child: GestureDetector(
                      onPanUpdate: (details) {
                        // Implementar arrastre manual si se desea
                      },
                      child: UserCard(user: _users[_currentIndex]),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Positioned(
      bottom: 100,
      left: 0,
      right: 0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          // Botón de rechazar
          FloatingActionButton(
            heroTag: "reject",
            onPressed: () => _onSwipe(false),
            backgroundColor: Colors.white,
            child: Icon(Icons.close, color: Colors.red, size: 32),
          ),
          
          // Botón de super like (opcional)
          FloatingActionButton(
            heroTag: "superlike",
            onPressed: () {
              Utils.showSnackBar(context, '¡Super Like! 💙');
              _onSwipe(true);
            },
            backgroundColor: Colors.blue,
            child: Icon(Icons.star, color: Colors.white, size: 28),
            mini: true,
          ),
          
          // Botón de me gusta
          FloatingActionButton(
            heroTag: "like",
            onPressed: () => _onSwipe(true),
            backgroundColor: AppTheme.primaryColor,
            child: Icon(Icons.favorite, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }

  Widget _buildMatchDialog() {
    return AnimatedBuilder(
      animation: _matchAnimation,
      builder: (context, child) {
        return Positioned.fill(
          child: Container(
            color: Colors.black.withOpacity(0.8 * _matchAnimation.value),
            child: Center(
              child: Transform.scale(
                scale: _matchAnimation.value,
                child: Container(
                  margin: EdgeInsets.all(32),
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '¡ES UN MATCH!',
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'A ti y a ${_matchedUser?.name} se gustan mutuamente',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 16),
                      ),
                      SizedBox(height: 24),
                      
                      // Fotos del match
                      if (_matchedUser != null && _matchedUser!.photos.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(60),
                          child: Image.network(
                            _matchedUser!.photos.first,
                            width: 120,
                            height: 120,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.grey[300],
                                  shape: BoxShape.circle,
                                ),
                                child: Icon(Icons.person, size: 60),
                              );
                            },
                          ),
                        ),
                      SizedBox(height: 24),
                      
                      Row(
                        children: [
                          Expanded(
                            child: CustomButton(
                              text: 'Enviar mensaje',
                              onPressed: () {
                                _closeMatchDialog();
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => MatchesScreen(),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      
                      TextButton(
                        onPressed: _closeMatchDialog,
                        child: Text('Seguir descubriendo'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _logout() async {
    await _userService.logout();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }
}