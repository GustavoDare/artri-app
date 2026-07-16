import 'package:artriapp/utils/index.dart';
import 'package:artriapp/view_models/remedy_view_model.dart';
import 'package:artriapp/models/api_responses/remedy.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'add_remedy_page.dart';
import 'package:go_router/go_router.dart';

class RemedyPage extends StatefulWidget {
  const RemedyPage({super.key});

  @override
  State<RemedyPage> createState() => _RemedyPageState();
}

class _RemedyPageState extends State<RemedyPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RemedyViewModel>().fetchRemedies();
    });
  }

  void _navigateToAddPage([Remedy? remedy]) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddRemedyPage(remedyToEdit: remedy)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: AppColors.darkGreen,
        elevation: 0,
        title: Text(
          'MEDICAMENTOS',
          style: GoogleFonts.montserrat(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go('/diary');
            }
          },
        ),
      ),
      body: Consumer<RemedyViewModel>(
        builder: (context, model, child) {
          if (model.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (model.isEmpty) {
            return _buildEmptyState();
          }

          return _buildLists(model);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Clique para adicionar o primeiro\nmedicamento que você faz uso no\nmomento',
              textAlign: TextAlign.center,
              style: GoogleFonts.montserrat(fontSize: 18, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            TextButton.icon(
              onPressed: () => _navigateToAddPage(),
              icon: const Icon(Icons.add_circle_outline, size: 36, color: AppColors.darkGreen),
              label: Text(
                'ADICIONAR',
                style: GoogleFonts.montserrat(fontSize: 22, color: AppColors.darkGreen, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLists(RemedyViewModel model) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: TextButton.icon(
              onPressed: () => _navigateToAddPage(),
              icon: const Icon(Icons.add_circle_outline, size: 32, color: AppColors.darkGreen),
              label: Text(
                'ADICIONAR',
                style: GoogleFonts.montserrat(fontSize: 20, color: AppColors.darkGreen, fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: 32),

          if (model.unconsumedRemedies.isNotEmpty) ...[
            Text('Remédios não consumidos', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 16),
            ...model.unconsumedRemedies.map((remedy) => _buildRemedyItem(remedy, model, isToday: true)),
            const SizedBox(height: 24),
          ],

          if (model.consumedRemedies.isNotEmpty) ...[
            Text('Remédios consumidos', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 16),
            ...model.consumedRemedies.map((remedy) => _buildRemedyItem(remedy, model, isToday: true)),
            const SizedBox(height: 24),
          ],

          if (model.otherDaysRemedies.isNotEmpty) ...[
            Text('Remédios para outro dia', style: GoogleFonts.montserrat(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey[800])),
            const SizedBox(height: 16),
            ...model.otherDaysRemedies.map((remedy) => _buildRemedyItem(remedy, model, isToday: false)),
          ],
        ],
      ),
    );
  }

  Widget _buildRemedyItem(Remedy remedy, RemedyViewModel model, {required bool isToday}) {
    final isTaken = model.isTaken(remedy.id);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        children: [
          if (isToday)
            GestureDetector(
              onTap: () => model.toggleTaken(remedy.id),
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: isTaken ? AppColors.darkGreen : Colors.black87, width: 2),
                  color: isTaken ? AppColors.darkGreen : Colors.transparent,
                ),
                child: isTaken ? const Icon(Icons.check, color: Colors.white, size: 18) : null,
              ),
            )
          else
          // Se não é para hoje, mostramos uma bolinha cinza e desabilitada
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.grey[400]!, width: 2),
                color: Colors.grey[200],
              ),
            ),

          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  remedy.name,
                  style: GoogleFonts.montserrat(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: isToday ? Colors.black87 : Colors.grey[600],
                    decoration: isTaken && isToday ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  '${remedy.dosage} • ${remedy.hour}',
                  style: GoogleFonts.montserrat(fontSize: 14, color: Colors.grey[500]),
                ),
              ],
            ),
          ),

          // Menu de Editar e Excluir
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.grey),
            onSelected: (value) {
              if (value == 'edit') {
                _navigateToAddPage(remedy);
              } else if (value == 'delete') {
                model.deleteRemedy(remedy.id);
              }
            },
            itemBuilder: (BuildContext context) => [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    const Icon(Icons.edit, color: Colors.black87, size: 20),
                    const SizedBox(width: 8),
                    Text('Editar', style: GoogleFonts.montserrat(color: Colors.black87)),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    const Icon(Icons.delete, color: Colors.red, size: 20),
                    const SizedBox(width: 8),
                    Text('Excluir', style: GoogleFonts.montserrat(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}