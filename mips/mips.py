"""
MIPS Pipeline Animation - Complete Architectural Redesign
Based on comprehensive checklist requirements:
- 3-channel routing (control/data/hazard)
- Explicit MUX blocks (ALUSrc, RegDst, Forward A/B, WB)
- Clear pipeline registers
- Visual hierarchy
"""

import tkinter as tk
import math

# Color semantics (STRICT)
COLORS = {
    'bg': '#1a1a2e',
    'canvas': '#0f0f1a',
    'panel': '#16213e',
    
    # Wire types - STRICT SEMANTICS
    'data': '#4a90d9',           # Blue solid - Datapath
    'ctrl': '#e74c3c',           # Red - Control signals
    'hazard': '#f39c12',         # Yellow/Orange - Stall/Flush
    'forward': '#2ecc71',        # Green - Forwarding paths
    'active': '#00ff88',         # Highlight
    
    # Modules
    'mod_dp': '#2980b9',         # Datapath modules
    'mod_ctrl': '#c0392b',       # Control modules
    'mod_mem': '#8e44ad',        # Memory modules
    'mod_pipe': '#34495e',       # Pipeline registers
    'mod_mux': '#16a085',        # MUX blocks
    'mod_haz': '#d35400',        # Hazard/Forwarding
    
    # Bit fields
    'bit_opcode': '#ff6b6b',
    'bit_rs': '#4ecdc4',
    'bit_rt': '#45b7d1',
    'bit_rd': '#96ceb4',
    'bit_shamt': '#dda0dd',
    'bit_funct': '#f7dc6f',
}

# Wire thickness hierarchy
WIRE_WIDTH = {
    'data': 4,      # Thickest - datapath
    'ctrl': 2,      # Thin - control
    'hazard': 2,    # Thin - hazard
    'forward': 2,   # Thin - forwarding
}

# MIPS encoding
REGISTERS = {'$zero': 0, '$t0': 8, '$t1': 9, '$s0': 16, '$s1': 17}
FUNCTS = {'add': 0x20, 'sub': 0x22, 'and': 0x24, 'or': 0x25, 'slt': 0x2A}

class MIPSPipelineAnimation:
    def __init__(self, root):
        self.root = root
        self.root.title("MIPS Pipeline - Educational Diagram")
        self.root.geometry("1800x950")
        self.root.configure(bg=COLORS['bg'])
        
        self.steps = []
        self.current_step = 0
        self.instruction_bits = ""
        self.wire_objs = {}
        self.data_values = {}
        
        self.setup_ui()
        self.define_layout()
        self.draw_all()
    
    def setup_ui(self):
        # Top control bar
        top = tk.Frame(self.root, bg=COLORS['panel'], height=50)
        top.pack(fill=tk.X, padx=5, pady=3)
        
        tk.Label(top, text="Instruction:", fg='#aaa', bg=COLORS['panel'],
                font=('Arial', 11)).pack(side=tk.LEFT, padx=8)
        
        self.entry = tk.Entry(top, width=22, font=('Consolas', 12), bg='#111', fg='#0f9')
        self.entry.insert(0, "add $t0, $s0, $s1")
        self.entry.pack(side=tk.LEFT, padx=5)
        
        for txt, cmd, bg in [("Parse", self.parse_instruction, '#2980b9'),
                             ("◀ Prev", self.prev_step, '#7f8c8d'),
                             ("Next ▶", self.next_step, '#27ae60'),
                             ("Reset", self.reset, '#c0392b')]:
            tk.Button(top, text=txt, command=cmd, bg=bg, fg='white',
                     font=('Arial', 10), width=7).pack(side=tk.LEFT, padx=2)
        
        self.lbl_step = tk.Label(top, text="Step: 0/0", fg='#0f9', bg=COLORS['panel'],
                                font=('Consolas', 12, 'bold'))
        self.lbl_step.pack(side=tk.LEFT, padx=15)
        
        self.lbl_stage = tk.Label(top, text="", fg='#f1c40f', bg=COLORS['panel'],
                                 font=('Arial', 12, 'bold'))
        self.lbl_stage.pack(side=tk.LEFT)
        
        # Legend bar
        legend = tk.Frame(self.root, bg='#0a0a15', height=30)
        legend.pack(fill=tk.X, padx=5, pady=2)
        
        for name, color, style in [
            ('Data (bus)', COLORS['data'], '━━━'),
            ('Control', COLORS['ctrl'], '───'),
            ('Stall/Flush', COLORS['hazard'], '- - -'),
            ('Forward', COLORS['forward'], '───'),
        ]:
            f = tk.Frame(legend, bg='#0a0a15')
            f.pack(side=tk.LEFT, padx=15)
            tk.Label(f, text=style, fg=color, bg='#0a0a15', font=('Consolas', 10, 'bold')).pack(side=tk.LEFT)
            tk.Label(f, text=f" {name}", fg='#888', bg='#0a0a15', font=('Arial', 9)).pack(side=tk.LEFT)
        
        # 32-bit instruction display
        bit_panel = tk.Frame(self.root, bg='#0a0a15', height=60)
        bit_panel.pack(fill=tk.X, padx=5, pady=2)
        
        tk.Label(bit_panel, text="32-bit:", fg='#666', bg='#0a0a15',
                font=('Consolas', 10)).pack(side=tk.LEFT, padx=5)
        
        self.bit_frame = tk.Frame(bit_panel, bg='#0a0a15')
        self.bit_frame.pack(side=tk.LEFT, padx=5)
        
        self.bit_labels = []
        for i in range(32):
            l = tk.Label(self.bit_frame, text="0", width=2, bg='#333', fg='white',
                        font=('Consolas', 9, 'bold'))
            l.grid(row=0, column=i, padx=0, pady=1)
            self.bit_labels.append(l)
        
        # Field legend
        for name, color in [('op', COLORS['bit_opcode']), ('rs', COLORS['bit_rs']),
                           ('rt', COLORS['bit_rt']), ('rd', COLORS['bit_rd']),
                           ('sh', COLORS['bit_shamt']), ('fn', COLORS['bit_funct'])]:
            tk.Label(bit_panel, text=f"■{name}", fg=color, bg='#0a0a15',
                    font=('Consolas', 9)).pack(side=tk.LEFT, padx=3)
        
        self.field_label = tk.Label(bit_panel, text="", fg='#888', bg='#0a0a15',
                                   font=('Consolas', 9))
        self.field_label.pack(side=tk.LEFT, padx=10)
        
        # Main area with canvas and info panel
        main = tk.Frame(self.root, bg=COLORS['bg'])
        main.pack(fill=tk.BOTH, expand=True, padx=5, pady=3)
        
        self.canvas = tk.Canvas(main, bg=COLORS['canvas'], highlightthickness=0)
        self.canvas.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        
        # Info panel
        info_panel = tk.Frame(main, bg='#0d1117', width=280)
        info_panel.pack(side=tk.RIGHT, fill=tk.Y, padx=3)
        info_panel.pack_propagate(False)
        
        tk.Label(info_panel, text="📋 Current Step", fg='#58a6ff', bg='#0d1117',
                font=('Arial', 11, 'bold')).pack(pady=8)
        
        self.info_text = tk.Text(info_panel, bg='#161b22', fg='#c9d1d9',
                                font=('Consolas', 9), wrap=tk.WORD, height=35,
                                highlightthickness=1, highlightbackground='#30363d')
        self.info_text.pack(fill=tk.BOTH, expand=True, padx=5, pady=5)
        
        self.info_text.tag_configure('header', foreground='#58a6ff', font=('Arial', 10, 'bold'))
        self.info_text.tag_configure('wire', foreground='#39d353')
        self.info_text.tag_configure('value', foreground='#ff7b72')
        self.info_text.tag_configure('desc', foreground='#8b949e')
        
        # Bottom status
        bottom = tk.Frame(self.root, bg=COLORS['panel'], height=40)
        bottom.pack(fill=tk.X, padx=5, pady=3)
        
        self.lbl_info = tk.Label(bottom, text="Parse instruction to begin",
                                fg='#ccc', bg=COLORS['panel'], font=('Consolas', 10))
        self.lbl_info.pack(pady=8)

    def define_layout(self):
        """
        Layout with 3-channel architecture:
        - Y_CTRL (60-120): Control signal channel
        - Y_DATA (180-380): Main datapath channel  
        - Y_HAZ (420-500): Hazard/Forwarding channel
        
        Stages: FETCH | IF/ID | DECODE | ID/EX | EXECUTE | EX/MEM | MEMORY | MEM/WB | WB
        X:      50    | 130   | 200    | 380   | 450     | 620    | 680    | 850    | 920
        """
        
        # === MODULES ===
        # Format: (x, y, w, h, color, display_name)
        self.modules = {
            # FETCH stage
            'PC': (50, 240, 50, 40, COLORS['mod_dp'], 'PC'),
            'IMEM': (120, 220, 80, 80, COLORS['mod_mem'], 'Instr\nMem'),
            
            # Pipeline register IF/ID
            'IF_ID': (220, 70, 20, 450, COLORS['mod_pipe'], ''),
            
            # DECODE stage
            'InstrSplit': (260, 200, 60, 60, '#555', 'Instr\nSplit'),  # Instruction splitter
            'CtrlUnit': (260, 80, 90, 70, COLORS['mod_ctrl'], 'Control\nUnit'),
            'RegFile': (340, 220, 80, 100, COLORS['mod_dp'], 'Register\nFile'),
            'SignExt': (340, 340, 60, 35, COLORS['mod_dp'], 'Sign\nExt'),
            'HazardUnit': (260, 440, 90, 50, COLORS['mod_haz'], 'Hazard\nUnit'),
            
            # Pipeline register ID/EX
            'ID_EX': (440, 70, 20, 450, COLORS['mod_pipe'], ''),
            
            # EXECUTE stage
            'MUX_A': (480, 210, 35, 50, COLORS['mod_mux'], 'MUX\nA'),
            'MUX_B': (480, 280, 35, 50, COLORS['mod_mux'], 'MUX\nB'),
            'ALUSrcMux': (480, 345, 35, 35, COLORS['mod_mux'], 'ALU\nSrc'),
            'ALU': (540, 240, 60, 80, COLORS['mod_dp'], 'ALU'),
            'RegDstMux': (540, 340, 50, 30, COLORS['mod_mux'], 'RegDst'),
            'FwdUnit': (480, 440, 70, 50, COLORS['mod_haz'], 'Forward\nUnit'),
            
            # Pipeline register EX/MEM
            'EX_MEM': (620, 70, 20, 450, COLORS['mod_pipe'], ''),
            
            # MEMORY stage
            'DMEM': (660, 220, 80, 100, COLORS['mod_mem'], 'Data\nMem'),
            
            # Pipeline register MEM/WB
            'MEM_WB': (760, 70, 20, 450, COLORS['mod_pipe'], ''),
            
            # WRITEBACK stage
            'WBMux': (800, 250, 40, 50, COLORS['mod_mux'], 'WB\nMux'),
        }
        
        # === WIRES ===
        # Format: (name, points, type, label, label_offset)
        # Types: 'data', 'ctrl', 'hazard', 'forward'
        self.wires = [
            # ==================== FETCH STAGE ====================
            ('pc_out', [(100, 260), (120, 260)], 'data', 'PC', (-5, -12)),
            ('instr', [(200, 260), (220, 260)], 'data', 'instr[31:0]', (5, -12)),
            
            # ==================== IF/ID → DECODE ====================
            # Instruction goes to splitter
            ('if_id_instr', [(240, 230), (260, 230)], 'data', '', (0, 0)),
            
            # Splitter outputs (fan-out)
            ('opcode', [(320, 210), (320, 140), (350, 140)], 'data', 'opcode', (-25, -10)),
            ('funct', [(320, 220), (320, 110), (350, 110)], 'data', 'funct', (-25, -10)),
            ('rs', [(320, 235), (340, 235)], 'data', 'rs', (5, -10)),
            ('rt', [(320, 250), (340, 250)], 'data', 'rt', (5, -10)),
            ('rd', [(290, 260), (290, 430), (440, 430)], 'data', 'rd', (-5, 15)),
            ('imm16', [(290, 250), (290, 355), (340, 355)], 'data', 'imm16', (-30, 0)),
            
            # Control Unit outputs → ID/EX (CONTROL CHANNEL - top)
            ('ctrl_regwrite', [(350, 85), (440, 85)], 'ctrl', 'RegWrite', (30, -8)),
            ('ctrl_memtoreg', [(350, 95), (440, 95)], 'ctrl', 'MemToReg', (30, -8)),
            ('ctrl_memwrite', [(350, 105), (440, 105)], 'ctrl', 'MemWrite', (30, -8)),
            ('ctrl_alusrc', [(350, 115), (440, 115)], 'ctrl', 'ALUSrc', (30, -8)),
            ('ctrl_aluop', [(350, 125), (440, 125)], 'ctrl', 'ALUOp', (30, -8)),
            ('ctrl_regdst', [(350, 135), (440, 135)], 'ctrl', 'RegDst', (30, -8)),
            
            # RegFile outputs → ID/EX
            ('rd1', [(420, 250), (440, 250)], 'data', 'rd1', (5, -10)),
            ('rd2', [(420, 290), (440, 290)], 'data', 'rd2', (5, -10)),
            
            # Sign extend output
            ('imm_ext', [(400, 357), (440, 357)], 'data', 'imm_ext', (5, -10)),
            
            # ==================== HAZARD UNIT (bottom channel) ====================
            ('stall_F', [(260, 470), (80, 470), (80, 280)], 'hazard', 'stall_F', (15, -10)),
            ('stall_D', [(260, 485), (230, 485), (230, 520)], 'hazard', 'stall_D', (-50, 0)),
            ('flush_E', [(350, 455), (440, 455)], 'hazard', 'flush_E', (30, -10)),
            
            # ==================== ID/EX → EXECUTE ====================
            # Data to MUXes
            ('ex_rd1', [(460, 235), (480, 235)], 'data', '', (0, 0)),
            ('ex_rd2', [(460, 305), (480, 305)], 'data', '', (0, 0)),
            ('ex_imm', [(460, 360), (480, 360)], 'data', '', (0, 0)),
            
            # MUX outputs to ALU
            ('mux_a_out', [(515, 235), (540, 250)], 'data', 'srcA', (5, -10)),
            ('mux_b_out', [(515, 305), (530, 305), (530, 360), (515, 360)], 'data', '', (0, 0)),
            ('alusrc_out', [(515, 362), (540, 280)], 'data', 'srcB', (5, 8)),
            
            # ALU output
            ('alu_result', [(600, 280), (620, 280)], 'data', 'ALU_out', (5, -10)),
            
            # RegDst MUX output (write register number)
            ('write_reg', [(590, 355), (620, 355)], 'data', 'WriteReg', (5, -10)),
            
            # ==================== FORWARDING UNIT (bottom channel) ====================
            ('fwd_a', [(510, 440), (510, 260), (480, 260)], 'forward', 'fwdA', (-35, 0)),
            ('fwd_b', [(530, 440), (530, 330), (480, 330)], 'forward', 'fwdB', (-35, 0)),
            
            # ==================== EX/MEM → MEMORY ====================
            ('mem_addr', [(640, 280), (660, 280)], 'data', 'addr', (5, -10)),
            ('mem_wdata', [(640, 310), (660, 310)], 'data', 'wdata', (5, -10)),
            
            # Memory output
            ('mem_rdata', [(740, 270), (760, 270)], 'data', 'rdata', (5, -10)),
            
            # Pass-through ALU result
            ('mem_alu', [(640, 250), (660, 250), (660, 220), (760, 220)], 'data', '', (0, 0)),
            
            # ==================== MEM/WB → WRITEBACK ====================
            ('wb_rdata', [(780, 270), (800, 270)], 'data', '', (0, 0)),
            ('wb_alu', [(780, 250), (790, 250), (790, 260), (800, 260)], 'data', '', (0, 0)),
            
            # WB MUX output → RegFile (SHORT VERTICAL BUS, not bottom wrap!)
            ('wb_data', [(840, 275), (860, 275), (860, 180), (400, 180), (400, 240), (420, 240)], 
             'data', 'WB_data', (10, -10)),
            
            # Write address feedback (similarly short)
            ('wb_addr', [(860, 290), (870, 290), (870, 170), (390, 170), (390, 260), (420, 260)],
             'data', 'WriteAddr', (10, 10)),
            
            # ==================== CONTROL PROPAGATION ====================
            # Control signals through pipeline (thin lines, top channel)
            ('ex_regwrite', [(460, 85), (620, 85)], 'ctrl', '', (0, 0)),
            ('mem_regwrite', [(640, 85), (760, 85)], 'ctrl', '', (0, 0)),
            ('wb_regwrite', [(780, 85), (850, 85), (850, 200), (425, 200), (425, 270)], 'ctrl', 'we', (-15, 0)),
        ]
    
    def draw_all(self):
        self.canvas.delete('all')
        self.wire_objs = {}
        
        # Stage labels
        stages = [
            (75, 'IF'), (170, 'ID'), (310, 'ID'), (510, 'EX'), (690, 'MEM'), (830, 'WB')
        ]
        for x, name in stages:
            self.canvas.create_text(x, 45, text=name, fill='#3a4a6a',
                                   font=('Arial', 14, 'bold'))
        
        # Draw routing channels (subtle background)
        self.canvas.create_rectangle(40, 70, 880, 150, fill='#12121f', outline='')  # Control
        self.canvas.create_text(15, 110, text='CTRL', fill='#333', font=('Arial', 8), angle=90)
        
        self.canvas.create_rectangle(40, 160, 880, 400, fill='#0f0f18', outline='')  # Data
        self.canvas.create_text(15, 280, text='DATA', fill='#333', font=('Arial', 8), angle=90)
        
        self.canvas.create_rectangle(40, 410, 880, 510, fill='#12121f', outline='')  # Hazard
        self.canvas.create_text(15, 460, text='HAZ', fill='#333', font=('Arial', 8), angle=90)
        
        # Draw pipeline register labels
        for name, y in [('IF/ID', 50), ('ID/EX', 50), ('EX/MEM', 50), ('MEM/WB', 50)]:
            if name == 'IF/ID':
                x = 230
            elif name == 'ID/EX':
                x = 450
            elif name == 'EX/MEM':
                x = 630
            else:
                x = 770
            self.canvas.create_text(x, y, text=name, fill='#556', font=('Consolas', 9, 'bold'))
        
        # Draw wires FIRST (under modules)
        for wire_def in self.wires:
            name, points, wtype, label, label_offset = wire_def
            
            color = COLORS.get(wtype, COLORS['data'])
            width = WIRE_WIDTH.get(wtype, 3)
            
            # Dash pattern for hazard signals
            dash = (4, 3) if wtype == 'hazard' else ()
            
            wire_id = self.canvas.create_line(
                points, fill=color, width=width,
                capstyle=tk.ROUND, joinstyle=tk.ROUND,
                dash=dash, tags=('wire', name)
            )
            self.wire_objs[name] = wire_id
            
            # Endpoint dot
            x2, y2 = points[-1]
            self.canvas.create_oval(x2-3, y2-3, x2+3, y2+3, fill=color, outline='')
            
            # Label
            if label:
                lx, ly = points[0]
                lx += label_offset[0]
                ly += label_offset[1]
                self.canvas.create_text(lx, ly, text=label, fill='#8cf',
                                       font=('Consolas', 8), anchor='w')
        
        # Draw modules
        for name, (x, y, w, h, color, display) in self.modules.items():
            # Shadow
            self.canvas.create_rectangle(x+2, y+2, x+w+2, y+h+2, fill='#080810', outline='')
            # Box
            self.canvas.create_rectangle(x, y, x+w, y+h, fill=color, outline='#fff', width=1,
                                        tags=('module', name))
            # Label
            if display:
                self.canvas.create_text(x+w/2, y+h/2, text=display, fill='white',
                                       font=('Arial', 8, 'bold'), justify='center')

    def parse_instruction(self):
        cmd = self.entry.get().strip()
        parts = cmd.replace(',', ' ').split()
        if not parts:
            return
        
        op = parts[0].lower()
        
        if op in FUNCTS:
            rd = REGISTERS.get(parts[1].strip(), 8)
            rs = REGISTERS.get(parts[2].strip(), 16)
            rt = REGISTERS.get(parts[3].strip(), 17)
            
            opcode = 0
            shamt = 0
            funct = FUNCTS[op]
            
            instr = (opcode << 26) | (rs << 21) | (rt << 16) | (rd << 11) | (shamt << 6) | funct
            self.instruction_bits = format(instr, '032b')
            
            self.data_values = {
                'pc_out': '0x00400000',
                'instr': f'0x{instr:08X}',
                'opcode': format(opcode, '06b'),
                'funct': format(funct, '06b'),
                'rs': f'${rs}',
                'rt': f'${rt}',
                'rd': f'${rd}',
                'rd1': '0x00000010',
                'rd2': '0x00000020',
                'alu_result': '0x00000030',
                'wb_data': '0x00000030',
            }
            
            self.update_bit_display()
            self.field_label.config(text=f"R: op={opcode:06b} rs={rs} rt={rt} rd={rd} fn={funct:06b}")
        
        self.steps = [
            {'name': 'FETCH', 'desc': 'PC → IMEM → 32-bit instruction',
             'wires': ['pc_out', 'instr'],
             'flow': [('pc_out', 'PC address to instruction memory'),
                     ('instr', 'Fetched 32-bit instruction')]},
            {'name': 'IF/ID Latch', 'desc': 'Instruction stored in IF/ID register',
             'wires': ['if_id_instr'],
             'flow': [('if_id_instr', 'Instruction passes to Decode stage')]},
            {'name': 'DECODE - Split', 'desc': 'Instruction split into fields',
             'wires': ['opcode', 'funct', 'rs', 'rt', 'rd', 'imm16'],
             'flow': [('opcode', 'Bits[31:26] → Control Unit'),
                     ('funct', 'Bits[5:0] → Control Unit'),
                     ('rs', 'Bits[25:21] → RegFile addr1'),
                     ('rt', 'Bits[20:16] → RegFile addr2'),
                     ('rd', 'Bits[15:11] → Write register'),
                     ('imm16', 'Bits[15:0] → Sign Extend')]},
            {'name': 'DECODE - Control', 'desc': 'Control signals generated',
             'wires': ['ctrl_regwrite', 'ctrl_memtoreg', 'ctrl_alusrc', 'ctrl_aluop', 'ctrl_regdst'],
             'flow': [('ctrl_regwrite', 'RegWrite=1 (will write result)'),
                     ('ctrl_alusrc', 'ALUSrc=0 (use register)'),
                     ('ctrl_regdst', 'RegDst=1 (use rd)')]},
            {'name': 'DECODE - RegRead', 'desc': 'Register values read',
             'wires': ['rd1', 'rd2', 'imm_ext'],
             'flow': [('rd1', 'Rs value = 0x10'),
                     ('rd2', 'Rt value = 0x20'),
                     ('imm_ext', 'Sign-extended immediate')]},
            {'name': 'HAZARD Check', 'desc': 'Hazard unit checks dependencies',
             'wires': ['stall_F', 'stall_D', 'flush_E'],
             'flow': [('stall_F', 'StallF=0 (no stall)'),
                     ('stall_D', 'StallD=0'),
                     ('flush_E', 'FlushE=0')]},
            {'name': 'EXECUTE - Forward', 'desc': 'Forwarding unit selects operands',
             'wires': ['ex_rd1', 'ex_rd2', 'fwd_a', 'fwd_b', 'mux_a_out'],
             'flow': [('fwd_a', 'ForwardA=00 (no forward)'),
                     ('fwd_b', 'ForwardB=00 (no forward)'),
                     ('mux_a_out', 'ALU srcA from register')]},
            {'name': 'EXECUTE - ALU', 'desc': f'ALU performs {op.upper()}',
             'wires': ['alusrc_out', 'alu_result', 'write_reg'],
             'flow': [('alusrc_out', 'ALU srcB from register'),
                     ('alu_result', f'Result = 0x30 (ADD)'),
                     ('write_reg', f'WriteReg = ${rd}')]},
            {'name': 'MEMORY', 'desc': 'Memory stage (pass-through for R-type)',
             'wires': ['mem_addr', 'mem_alu'],
             'flow': [('mem_addr', 'Address (unused for R-type)'),
                     ('mem_alu', 'ALU result passed through')]},
            {'name': 'WRITEBACK', 'desc': 'Result written to register file',
             'wires': ['wb_rdata', 'wb_alu', 'wb_data', 'wb_regwrite'],
             'flow': [('wb_data', 'WB MUX selects ALU result'),
                     ('wb_regwrite', 'Write enable active'),
                     ('wb_addr', f'Write to ${rd}')]},
        ]
        
        self.current_step = 0
        self.update_display()

    def update_bit_display(self):
        bits = self.instruction_bits
        colors = []
        for i in range(32):
            pos = 31 - i
            if pos >= 26: colors.append(COLORS['bit_opcode'])
            elif pos >= 21: colors.append(COLORS['bit_rs'])
            elif pos >= 16: colors.append(COLORS['bit_rt'])
            elif pos >= 11: colors.append(COLORS['bit_rd'])
            elif pos >= 6: colors.append(COLORS['bit_shamt'])
            else: colors.append(COLORS['bit_funct'])
        
        for i, (label, color) in enumerate(zip(self.bit_labels, colors)):
            label.config(text=bits[i], bg=color)

    def update_display(self):
        if not self.steps:
            return
        
        self.lbl_step.config(text=f"Step: {self.current_step+1}/{len(self.steps)}")
        step = self.steps[self.current_step]
        self.lbl_stage.config(text=step['name'])
        self.lbl_info.config(text=step['desc'])
        
        # Reset wire colors
        for name, wid in self.wire_objs.items():
            wire_def = next((w for w in self.wires if w[0] == name), None)
            if wire_def:
                wtype = wire_def[2]
                color = COLORS.get(wtype, COLORS['data'])
                self.canvas.itemconfig(wid, fill=color)
        
        # Highlight active wires
        for wire_name in step['wires']:
            if wire_name in self.wire_objs:
                self.canvas.itemconfig(self.wire_objs[wire_name], fill=COLORS['active'])
                wire_def = next((w for w in self.wires if w[0] == wire_name), None)
                if wire_def:
                    value = self.data_values.get(wire_name, '')
                    self.animate_packet(wire_def[1], value)
        
        # Update info panel
        self.info_text.config(state=tk.NORMAL)
        self.info_text.delete('1.0', tk.END)
        self.info_text.insert(tk.END, f"{step['name']}\n\n", 'header')
        
        if 'flow' in step:
            for wire, desc in step['flow']:
                self.info_text.insert(tk.END, f"▸ ", 'desc')
                self.info_text.insert(tk.END, f"{wire}\n", 'wire')
                val = self.data_values.get(wire, '')
                if val:
                    self.info_text.insert(tk.END, f"  = {val}\n", 'value')
                self.info_text.insert(tk.END, f"  {desc}\n\n", 'desc')
        
        self.info_text.config(state=tk.DISABLED)

    def animate_packet(self, points, value=''):
        if len(points) < 2:
            return
        
        display = value[:12] if value else "→"
        
        packet = self.canvas.create_text(points[0][0], points[0][1],
                                        text=display, fill='#fff',
                                        font=('Consolas', 8, 'bold'), tags='packet')
        
        bbox = self.canvas.bbox(packet)
        if bbox:
            bg = self.canvas.create_rectangle(bbox[0]-2, bbox[1]-1, bbox[2]+2, bbox[3]+1,
                                             fill='#1a1a2e', outline=COLORS['active'],
                                             tags='packet')
            self.canvas.tag_raise(packet, bg)
        
        segments = []
        total = 0
        for i in range(len(points)-1):
            x1, y1 = points[i]
            x2, y2 = points[i+1]
            d = math.sqrt((x2-x1)**2 + (y2-y1)**2)
            segments.append((x1, y1, x2, y2, d))
            total += d
        
        if total == 0:
            return
        
        frames = 40
        
        def move(f):
            if f > frames:
                self.root.after(600, lambda: self.canvas.delete('packet'))
                return
            
            t = f / frames
            target = t * total
            traveled = 0
            x, y = points[0]
            
            for x1, y1, x2, y2, d in segments:
                if traveled + d >= target:
                    if d > 0:
                        s = (target - traveled) / d
                        x = x1 + (x2-x1)*s
                        y = y1 + (y2-y1)*s
                    break
                traveled += d
            
            self.canvas.coords(packet, x, y)
            bbox = self.canvas.bbox(packet)
            if bbox:
                for item in self.canvas.find_withtag('packet'):
                    if self.canvas.type(item) == 'rectangle':
                        self.canvas.coords(item, bbox[0]-2, bbox[1]-1, bbox[2]+2, bbox[3]+1)
            self.canvas.tag_raise(packet)
            self.root.after(18, move, f+1)
        
        move(0)

    def next_step(self):
        if not self.steps:
            self.lbl_info.config(text="Click Parse first!")
            return
        if self.current_step < len(self.steps) - 1:
            self.current_step += 1
            self.update_display()

    def prev_step(self):
        if self.current_step > 0:
            self.current_step -= 1
            self.update_display()

    def reset(self):
        self.current_step = 0
        self.steps = []
        self.canvas.delete('packet')
        self.draw_all()
        self.lbl_step.config(text="Step: 0/0")
        self.lbl_stage.config(text="")
        self.lbl_info.config(text="Parse instruction to begin")
        
        for label in self.bit_labels:
            label.config(text="0", bg='#333')
        self.field_label.config(text="")
        
        self.info_text.config(state=tk.NORMAL)
        self.info_text.delete('1.0', tk.END)
        self.info_text.insert(tk.END, "Enter instruction and Parse\nto see pipeline flow.\n", 'desc')
        self.info_text.config(state=tk.DISABLED)


if __name__ == "__main__":
    root = tk.Tk()
    app = MIPSPipelineAnimation(root)
    root.mainloop()
