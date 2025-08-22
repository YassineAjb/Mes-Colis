// lib/views/runsheets_view.dart
import 'package:flutter/material.dart';
import 'package:mescolis/viewmodels/runsheet_view_model.dart';
import 'package:provider/provider.dart';

class RunsheetsView extends StatefulWidget {
  const RunsheetsView({Key? key}) : super(key: key);

  @override
  State<RunsheetsView> createState() => _RunsheetsViewState();
}

class _RunsheetsViewState extends State<RunsheetsView> {
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _fromDateController = TextEditingController();
  final TextEditingController _toDateController = TextEditingController();
  int? _selectedCarId;
  bool _showFilters = false;
  /*
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final viewModel = context.read<RunsheetViewModel>();
      await viewModel.fetchCars();
      viewModel.fetchRunsheets(refresh: true);
    });

    _scrollController.addListener(_onScroll);
  }
  */
  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) async {
    final viewModel = context.read<RunsheetViewModel>();
    
    try {
      // Make sure cars are fetched first
      await viewModel.fetchCars();
      print('Cars fetched: ${viewModel.cars.length}'); // Debug line
      
      // Then fetch runsheets
      await viewModel.fetchRunsheets(refresh: true);
      
      // Force UI update
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      print('Error during initialization: $e'); // Debug line
    }
  });

  _scrollController.addListener(_onScroll);
}

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent * 0.8) {
      context.read<RunsheetViewModel>().fetchRunsheets();
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _fromDateController.dispose();
    _toDateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.teal[50],
      appBar: AppBar(
        title: const Text('Liste des tournées', style: TextStyle(fontWeight: FontWeight.w600)),
        backgroundColor:Color(0xFF3b6c7b),
        foregroundColor:Colors.white, 
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: Colors.teal[200],
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(
              _showFilters ? Icons.filter_alt : Icons.filter_alt_outlined,
              color: _showFilters ? Colors.teal[200] : Colors.teal[50],
            ),
            onPressed: () => setState(() => _showFilters = !_showFilters),
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.teal[50]),
            onPressed: () => _refreshData(),
          ),
        ],
      ),
      body: Consumer<RunsheetViewModel>(
        builder: (context, runsheetViewModel, child) {
          return Column(
            children: [
              // Filters Section
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: _showFilters ? null : 0,
                child: _showFilters ? _buildFiltersSection(runsheetViewModel) : null,
              ),
              
              // Content
              Expanded(
                child: _buildContent(runsheetViewModel),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFiltersSection(RunsheetViewModel viewModel) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Row(
            children: [
              // Search Field with real-time search
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search...',
                    prefixIcon: const Icon(Icons.search, size: 20),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.green[600]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  onChanged: (value) {
                    // Apply search in real-time
                    viewModel.setSearchQuery(value);
                  },
                ),
              ),
              const SizedBox(width: 16),
              
              // Car Dropdown
              Expanded(
                flex: 2,
                child: DropdownButtonFormField<int>(
                  value: _selectedCarId,
                  decoration: InputDecoration(
                    labelText: 'Select Car',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  items: [
                    const DropdownMenuItem<int>(
                      value: null,
                      child: Text('All Cars'),
                    ),
                    ...viewModel.cars.map((car) => DropdownMenuItem<int>(
                      value: car.carId,
                      child: Text(car.carName ?? 'Car #${car.carId}'),
                    )),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedCarId = value);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              // From Date
              Expanded(
                child: TextFormField(
                  controller: _fromDateController,
                  decoration: InputDecoration(
                    labelText: 'From Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(_fromDateController),
                ),
              ),
              const SizedBox(width: 16),
              
              // To Date  
              Expanded(
                child: TextFormField(
                  controller: _toDateController,
                  decoration: InputDecoration(
                    labelText: 'To Date',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey[300]!),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    labelStyle: TextStyle(color: Colors.grey[600], fontSize: 14),
                  ),
                  readOnly: true,
                  onTap: () => _selectDate(_toDateController),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.search, size: 18),
                  label: const Text('Search'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _resetFilters,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Reset'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red[400],
                    side: BorderSide(color: Colors.red[400]!),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContent(RunsheetViewModel runsheetViewModel) {
    if (runsheetViewModel.isLoading && runsheetViewModel.runsheets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading runsheets...', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    if (runsheetViewModel.errorMessage != null) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red[400],
              ),
              const SizedBox(height: 16),
              Text(
                'Error Loading Data',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                runsheetViewModel.errorMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => _refreshData(),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Try Again'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (runsheetViewModel.runsheets.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.assignment_outlined,
                size: 64,
                color: Colors.grey[400],
              ),
              const SizedBox(height: 16),
              Text(
                'No Runsheets Found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[800],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Try adjusting your filters or refresh the page',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => _refreshData(),
      child: Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // Table Header
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(12),
                  topRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  //_buildHeaderCell('Barcode', flex: 2),
                  _buildHeaderCell('Car', flex: 2),
                  //_buildHeaderCell('Total Orders', flex: 2),
                  _buildHeaderCell('Date', flex: 2),
                  _buildHeaderCell('Status', flex: 2),
                  _buildHeaderCell('Action', flex: 1),
                ],
              ),
            ),
            
            // Table Content
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                itemCount: runsheetViewModel.runsheets.length + 1,
                itemBuilder: (context, index) {
                  if (index == runsheetViewModel.runsheets.length) {
                    return runsheetViewModel.isLoading
                        ? Container(
                            padding: const EdgeInsets.all(16.0),
                            child: const Center(child: CircularProgressIndicator()),
                          )
                        : const SizedBox.shrink();
                  }

                  final runsheet = runsheetViewModel.runsheets[index];
                  return _buildTableRow(runsheet, index);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 13,
          color: Colors.grey[700],
        ),
      ),
    );
  }

  Widget _buildTableRow(dynamic runsheet, int index) {
    final isEven = index % 2 == 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isEven ? Colors.white : Colors.grey[25],
      ),
      child: Row(
        children: [
          // Barcode/Runsheet Number
          // Expanded(
          //   flex: 2,
          //   child: Text(
          //     runsheet.barcode ?? runsheet.runsheetNumber ?? 'N/A',
          //     style: TextStyle(
          //       fontWeight: FontWeight.w500,
          //       color: Colors.grey[800],
          //       fontSize: 14,
          //     ),
          //   ),
          // ),
          
          // Car (Registration Number or Car Name)
          Expanded(
            flex: 2,
            child: Text(
              runsheet.registrationNumber ?? runsheet.carName ?? '-',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          
          // Total Orders
          // Expanded(
          //   flex: 1,
          //   child: Text(
          //     '${runsheet.ordersCount ?? 0}',
          //     style: TextStyle(
          //       color: Colors.grey[700],
          //       fontSize: 14,
          //     ),
          //   ),
          // ),
          
          // Date
          Expanded(
            flex: 2,
            child: Text(
              runsheet.date ?? '-',
              style: TextStyle(
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          
          // Status
          Expanded(
            flex: 2,
            child: _buildStatusChip(runsheet.status),
          ),
          
          // Action
          Expanded(
            flex: 1,
            child: IconButton(
              icon: Icon(Icons.visibility_outlined, size: 18, color: Colors.grey[600]),
              onPressed: () => _showRunsheetDetails(context, runsheet),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(String? status) {
    if (status == null) return const Text('-');
    
    Color backgroundColor;
    Color textColor;
    
    switch (status.toLowerCase()) {
      case 'treated':
        backgroundColor = Colors.green[100]!;
        textColor = Colors.green[700]!;
        break;
      case 'untreated':
        backgroundColor = Colors.red[100]!;
        textColor = Colors.red[700]!;
        break;
      default:
        backgroundColor = Colors.grey[100]!;
        textColor = Colors.grey[700]!;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  void _selectDate(TextEditingController controller) async {
    final date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    
    if (date != null) {
      controller.text = '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    }
  }

  void _applyFilters() {
    final viewModel = context.read<RunsheetViewModel>();
    viewModel.setFilters(
      carId: _selectedCarId,
      fromDate: _fromDateController.text.isNotEmpty ? _fromDateController.text : null,
      toDate: _toDateController.text.isNotEmpty ? _toDateController.text : null,
      searchQuery: _searchController.text.isNotEmpty ? _searchController.text : null,
    );
  }

  void _resetFilters() {
    setState(() {
      _searchController.clear();
      _fromDateController.clear();
      _toDateController.clear();
      _selectedCarId = null;
    });
    
    final viewModel = context.read<RunsheetViewModel>();
    viewModel.clearFilters();
  }

  Future<void> _refreshData() async {
    final viewModel = context.read<RunsheetViewModel>();
    await viewModel.fetchCars();
    viewModel.fetchRunsheets(refresh: true);
  }

  void _showRunsheetDetails(BuildContext context, dynamic runsheet) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(Icons.assignment, color: Colors.teal[600], size: 24),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Runsheet #${runsheet.barcode ?? runsheet.runsheetId}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                if (runsheet.barcode != null) 
                  _buildDetailRow('Barcode', runsheet.barcode!),
                if (runsheet.runsheetNumber != null) 
                  _buildDetailRow('Number', runsheet.runsheetNumber!),
                if (runsheet.registrationNumber != null) 
                  _buildDetailRow('Vehicle', runsheet.registrationNumber!),
                if (runsheet.deliverymanName != null) 
                  _buildDetailRow('Deliveryman', runsheet.deliverymanName!),
                if (runsheet.date != null) 
                  _buildDetailRow('Date', runsheet.date!),
                if (runsheet.status != null) 
                  _buildDetailRow('Status', runsheet.status!),
                if (runsheet.ordersCount != null) 
                  _buildDetailRow('Orders Count', runsheet.ordersCount.toString()),
                if (runsheet.totalPrice != null)
                  _buildDetailRow('Total Price', '${runsheet.totalPrice!.toStringAsFixed(2)} TND'),
                if (runsheet.type != null)
                  _buildDetailRow('Type', runsheet.type!),
                if (runsheet.agencyName != null)
                  _buildDetailRow('Agency', runsheet.agencyName!),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Close', style: TextStyle(color: Colors.grey[600])),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: Colors.grey[800],
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}