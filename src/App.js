import React, { useState, useEffect, useRef } from 'react';
import Draggable from 'react-draggable';
import html2canvas from 'html2canvas';
import './App.css';
import 'bootstrap/dist/css/bootstrap.min.css';
import { Bold, Italic, Underline, Plus, Trash2, AArrowUp, AArrowDown, Eye, EyeOff, ChevronUp, ChevronDown, ChevronRight, ChevronLeft, Undo, Redo } from 'lucide-react';
import Select from 'react-select';


const TextCanvas = () => {
  const [textItems, setTextItems] = useState([]);
  const [inputValue, setInputValue] = useState('');
  const [fontSize, setFontSize] = useState('16px');
  const [color, setColor] = useState('#000000');
  const [selectedItemId, setSelectedItemId] = useState(null);
  const [showAlert, setShowAlert] = useState(false);
  const [sidebarCollapsed, setSidebarCollapsed] = useState(false);
  const canvasRef = useRef(null);
  const [isEditing, setIsEditing] = useState(false);
  const [currentEditingId, setCurrentEditingId] = useState(null);
  const [undoStack, setUndoStack] = useState([]);
  const [redoStack, setRedoStack] = useState([]);

  const fontOptions = [
    { value: 'Arial', label: 'Arial' },
    { value: 'Verdana', label: 'Verdana' },
    { value: 'Helvetica', label: 'Helvetica' },
    { value: 'Times New Roman', label: 'Times New Roman' },
    { value: 'Courier New', label: 'Courier New' },
    { value: 'Georgia', label: 'Georgia' },
    { value: 'Palatino', label: 'Palatino' },
    { value: 'Garamond', label: 'Garamond' },
    { value: 'Bookman', label: 'Bookman' },
    { value: 'Comic Sans MS', label: 'Comic Sans MS' },
    { value: 'Trebuchet MS', label: 'Trebuchet MS' },
    { value: 'Arial Black', label: 'Arial Black' },
    { value: 'Impact', label: 'Impact' }
  ];

  const fontSizeOptions = [];
  for (let size = 8; size <= 72; size += 2) {
    fontSizeOptions.push({ value: `${size}px`, label: `${size}px` });
  }

  useEffect(() => {
    document.title = 'Textify - Text Canvas';
    const savedCanvas = localStorage.getItem('canvasItems');
    if (savedCanvas) {
      setTextItems(JSON.parse(savedCanvas));
    }
    const handleClickOutside = (event) => {
      if (event.target.classList.contains('canvas')) {
        setSelectedItemId(null);
        if (isEditing) {
          stopEditing();
        }
      }
    };

    document.addEventListener('mousedown', handleClickOutside);
    return () => {
      document.removeEventListener('mousedown', handleClickOutside);
    };
  }, []);

  useEffect(() => {
    const handleKeyPress = (event) => {
      if (event.key === 'Delete' && selectedItemId) {
        deleteText(selectedItemId);
      }
      if (event.key === 'Escape') {
        setSelectedItemId(null);
        if (isEditing) {
          stopEditing();
        }
      }
    }

    document.addEventListener('keydown', handleKeyPress);
    return () => {
      document.removeEventListener('keydown', handleKeyPress);
    };
  })

  useEffect(() => {
    localStorage.setItem('canvasItems', JSON.stringify(textItems));
  }, [textItems]);


  const saveStateForUndo = () => {
    setUndoStack([...undoStack, textItems]);
    setRedoStack([]);
  };

  const undo = () => {
    if (undoStack.length > 0) {
      const lastState = undoStack.pop();
      setRedoStack([...redoStack, textItems]);
      setTextItems(lastState);
      setUndoStack([...undoStack]);
    }
  };

  const redo = () => {
    if (redoStack.length > 0) {
      const nextState = redoStack.pop();
      setUndoStack([...undoStack, textItems]);
      setTextItems(nextState);
      setRedoStack([...redoStack]);
    }
  };



  const addText = () => {
    const id = Date.now();
    setTextItems([
      ...textItems,
      {
        id: id,
        content: '',
        x: 0,
        y: 0,
        fontSize,
        color,
        width: 'auto',
        fontWeight: 'normal',
        fontStyle: 'normal',
        textDecoration: 'none',
        fontFamily: 'Arial',
        visible: true
      }
    ]);
    saveStateForUndo();
    setSelectedItemId(id);
    setIsEditing(true);
    setCurrentEditingId(id);
    setInputValue('');
  };

  const handleDrag = (id, deltaX, deltaY) => {
    saveStateForUndo();
    setTextItems((prevItems) =>
      prevItems.map((item) =>
        item.id === id ? { ...item, x: item.x + deltaX, y: item.y + deltaY } : item
      )
    );
  };

  const deleteText = (id) => {
    saveStateForUndo();
    setTextItems(textItems.filter((item) => item.id !== id));
    if (selectedItemId === id) setSelectedItemId(null);
    setInputValue('');
  };

  const selectTextItem = (id) => {
    setSelectedItemId(id);
    const selectedItem = textItems.find(item => item.id === id);
    if (selectedItem) {
      setInputValue(selectedItem.content);
      setFontSize(selectedItem.fontSize);
      setColor(selectedItem.color);
    }
  };

  const updateSelectedItem = (updatedItem) => {
    saveStateForUndo();
    setTextItems(textItems.map(item =>
      item.id === updatedItem.id
        ? { ...item, content: updatedItem.content, fontSize: updatedItem.fontSize, color: updatedItem.color, fontWeight: updatedItem.fontWeight, fontStyle: updatedItem.fontStyle, textDecoration: updatedItem.textDecoration }
        : item
    ));
  };

  const handleColorChange = (e) => {
    saveStateForUndo();
    const newColor = e.target.value;
    setColor(newColor);
    if (selectedItemId) {
      const updatedItem = textItems.find(item => item.id === selectedItemId);
      updateSelectedItem({ ...updatedItem, color: newColor });
    }
  };

  const handleFontSizeChange = (e) => {
    saveStateForUndo();
    const newSize = e.target.value;
    setFontSize(newSize);
    if (selectedItemId) {
      const updatedItem = textItems.find(item => item.id === selectedItemId);
      updateSelectedItem({ ...updatedItem, fontSize: newSize });
    }
  };

  const startEditing = (id) => {
    setCurrentEditingId(id);
    setIsEditing(true);
  };

  const stopEditing = () => {
    setIsEditing(false);
    setCurrentEditingId(null);
  };

  const handleInputChange = (e) => {
    setInputValue(e.target.value);
  };

  const handleInputBlur = () => {
    if (currentEditingId) {
      saveStateForUndo();
      const updatedItem = textItems.find(item => item.id === currentEditingId);
      if (updatedItem) {
        updateSelectedItem({ ...updatedItem, content: inputValue });
        stopEditing();
      }
    }
  };

  const handleInputKeyDown = (e) => {
    if (e.key === 'Enter') {
      handleInputBlur();
    }
  };

  const exportCanvas = () => {
    const canvasElement = document.querySelector('.canvas');
    html2canvas(canvasElement).then((canvas) => {
      const link = document.createElement('a');
      link.download = 'canvas.png';
      link.href = canvas.toDataURL();
      link.click();
    });
    setShowAlert(true);
    setTimeout(() => setShowAlert(false), 3000);
  };

  const toggleItemVisibility = (id) => {
    setTextItems(textItems.map(item =>
      item.id === id ? { ...item, visible: !item.visible } : item
    ));
  };

  const moveItem = (id, direction) => {
    const index = textItems.findIndex(item => item.id === id);
    if (direction === 'up' && index > 0) {
      const newItems = [...textItems];
      [newItems[index - 1], newItems[index]] = [newItems[index], newItems[index - 1]];
      setTextItems(newItems);
    } else if (direction === 'down' && index < textItems.length - 1) {
      const newItems = [...textItems];
      [newItems[index], newItems[index + 1]] = [newItems[index + 1], newItems[index]];
      setTextItems(newItems);
    }
  };

  const handleFontFamilyChange = (selectedOption) => {
    saveStateForUndo();
    const newFontFamily = selectedOption.value;
    setTextItems(textItems.map(item =>
      item.id === selectedItemId ? { ...item, fontFamily: newFontFamily } : item
    ));
  };

  const increaseFontSize = () => {
    if (selectedItemId) {
      saveStateForUndo();
      const updatedItem = textItems.find(item => item.id === selectedItemId);
      const currentSize = parseInt(updatedItem.fontSize);
      const newSize = `${currentSize + 2}px`;
      updateSelectedItem({ ...updatedItem, fontSize: newSize });
      setFontSize(newSize);
    }
  };

  const decreaseFontSize = () => {
    if (selectedItemId) {
      saveStateForUndo();
      const updatedItem = textItems.find(item => item.id === selectedItemId);
      const currentSize = parseInt(updatedItem.fontSize);
      const newSize = `${Math.max(currentSize - 2, 8)}px`;
      updateSelectedItem({ ...updatedItem, fontSize: newSize });
      setFontSize(newSize);
    }
  };


  return (
    <div className="container-fluid">
      <div className="row">
        <aside className={`col-auto border-end p-3 bg-light ${sidebarCollapsed ? 'collapsed' : ''}`} style={{ width: sidebarCollapsed ? '80px' : '290px', transition: 'width 0.3s' }}>
          <div className="d-flex justify-content-between align-items-center mb-3">
            <h5 className={`m-0 ${sidebarCollapsed ? 'd-none' : ''}`}>Text Layers</h5>
            <button className="btn btn-sm btn-outline-secondary" onClick={() => setSidebarCollapsed(!sidebarCollapsed)}>
              {sidebarCollapsed ? <ChevronRight /> : <ChevronLeft />}
            </button>
          </div>
          {!sidebarCollapsed && (
            <ul className="list-group overflow-auto" style={{
              maxHeight: 'calc(100vh - 100px)',
              transition: 'max-height 0.3s'
            }}>
              {textItems.map((item, index) => (
                <li
                  key={item.id}
                  className={`list-group-item d-flex justify-content-between align-items-center ${selectedItemId === item.id ? 'active' : ''}`}
                  style={{ cursor: 'pointer' }}
                >
                  <div className="d-flex align-items-center" style={{ width: '40%' }} onClick={() => selectTextItem(item.id)}>
                    <span className="text-truncate">{item.content || 'Untitled'}</span>
                  </div>
                  <div>
                    <button className={`btn btn-sm btn-outline-secondary me-1 ${selectedItemId === item.id ? 'text-white' : ''}`} onClick={() => toggleItemVisibility(item.id)}>
                      {item.visible ? <Eye size={14} /> : <EyeOff size={14} />}
                    </button>
                    <button className={`btn btn-sm btn-outline-secondary me-1 ${selectedItemId === item.id ? 'text-white' : ''}`} onClick={() => moveItem(item.id, 'up')} disabled={index === 0}>
                      <ChevronUp size={14} />
                    </button>
                    <button className={`btn btn-sm btn-outline-secondary ${selectedItemId === item.id ? 'text-white' : ''}`} onClick={() => moveItem(item.id, 'down')} disabled={index === textItems.length - 1}>
                      <ChevronDown size={14} />
                    </button>
                  </div>
                </li>
              ))}
            </ul>
          )}
        </aside>
        <main className="col">
          <div className="container py-5">
            <h1 className="text-center mb-5">Text Canvas</h1>
            <div className="card mb-4 shadow-sm">
              <div className="card-body">
                <div className="row g-3 align-items-center">
                  <div className='col-auto'>
                    <button className="btn btn-outline-primary" onClick={undo} disabled={undoStack.length === 0}>
                      <Undo />
                    </button>
                  </div>
                  <div className='col-auto'>
                    <button className="btn btn-outline-primary" onClick={redo} disabled={redoStack.length === 0}>
                      <Redo />
                    </button>
                  </div>
                  <div className='col-md-2'>
                    <Select
                      options={fontOptions}
                      onChange={handleFontFamilyChange}
                      placeholder="Select font..."
                      defaultValue={fontOptions[0]}
                    />
                  </div>
                  <div className="col-auto">
                    <div className="btn-group" role="group">
                      <button className={`btn ${selectedItemId && textItems.find(item => item.id === selectedItemId)?.fontWeight === 'bold' ? 'btn-primary' : 'btn-outline-primary'}`} onClick={() => {
                        const updatedItem = textItems.find(item => item.id === selectedItemId);
                        if (updatedItem) {
                          updateSelectedItem({ ...updatedItem, fontWeight: textItems.find(item => item.id === selectedItemId)?.fontWeight === 'bold' ? 'normal' : 'bold' });
                        }
                      }}>
                        <Bold size={18} />
                      </button>
                      <button className={`btn ${selectedItemId && textItems.find(item => item.id === selectedItemId)?.fontStyle === 'italic' ? 'btn-primary' : 'btn-outline-primary'}`} onClick={() => {
                        const updatedItem = textItems.find(item => item.id === selectedItemId);
                        if (updatedItem) {
                          updateSelectedItem({ ...updatedItem, fontStyle: textItems.find(item => item.id === selectedItemId)?.fontStyle === 'italic' ? 'normal' : 'italic' });
                        }
                      }}>
                        <Italic size={18} />
                      </button>
                      <button className={`btn ${selectedItemId && textItems.find(item => item.id === selectedItemId)?.textDecoration === 'underline' ? 'btn-primary' : 'btn-outline-primary'}`} onClick={() => {
                        const updatedItem = textItems.find(item => item.id === selectedItemId);
                        if (updatedItem) {
                          updateSelectedItem({ ...updatedItem, textDecoration: textItems.find(item => item.id === selectedItemId)?.textDecoration === 'underline' ? 'none' : 'underline' });
                        }
                      }}>
                        <Underline size={18} />
                      </button>
                    </div>
                  </div>
                  <div className="col-auto">
                    <div className="btn-group" role="group">
                      <button className="btn btn-outline-primary" onClick={decreaseFontSize}>
                        <AArrowDown />
                      </button>
                      <button className="btn btn-outline-primary" onClick={increaseFontSize}>
                        <AArrowUp />
                      </button>
                    </div>
                  </div>
                  <div className="col-md-auto">
                    <select
                      className="form-select"
                      value={fontSize}
                      onChange={handleFontSizeChange}
                    >
                      {fontSizeOptions.map((option) => (
                        <option key={option.value} value={option.value}>{option.label}</option>
                      ))}
                    </select>
                  </div>
                  <div className="col-auto">
                    <input
                      type="color"
                      className="form-control form-control-color"
                      value={color}
                      onChange={handleColorChange}
                      title="Choose text color"
                    />
                  </div>
                  <div className="col-auto">
                    <button className="btn btn-primary" onClick={addText}>
                      <Plus size={18} />
                    </button>
                  </div>
                  {selectedItemId && (
                    <div className="col-auto">
                      <button className="btn btn-danger" onClick={() => deleteText(selectedItemId)}>
                        <Trash2 size={18} />
                      </button>
                    </div>
                  )}
                  <div className="col-auto ms-auto">
                    <button className="btn btn-success" onClick={exportCanvas}>
                      Export Canvas
                    </button>
                  </div>
                </div>
              </div>
            </div>

            <div ref={canvasRef} className="canvas border border-4 border-dashed rounded p-3 bg-light position-relative" style={{ height: '400px', overflow: 'hidden' }}>
              {textItems.map((item) => (
                item.visible && (
                  <Draggable
                    key={item.id}
                    position={{ x: item.x, y: item.y }}
                    onDrag={(e, data) => handleDrag(item.id, data.deltaX, data.deltaY)}
                  >
                    <div
                      className={`text-item position-absolute ${selectedItemId === item.id ? 'selected' : ''}`}
                      onClick={() => selectTextItem(item.id)}
                      onDoubleClick={() => startEditing(item.id)}
                      style={{
                        fontSize: item.fontSize,
                        color: item.color,
                        fontWeight: item.fontWeight,
                        fontStyle: item.fontStyle,
                        textDecoration: item.textDecoration,
                        fontFamily: item.fontFamily,
                        cursor: 'move'
                      }}
                    >
                      {isEditing && currentEditingId === item.id ? (
                        <input
                          type="text"
                          value={inputValue}
                          onChange={handleInputChange}
                          onBlur={handleInputBlur}
                          onKeyDown={handleInputKeyDown}
                          autoFocus
                          style={{
                            fontSize: item.fontSize,
                            color: item.color,
                            fontWeight: item.fontWeight,
                            fontStyle: item.fontStyle,
                            textDecoration: item.textDecoration,
                            border: 'none',
                            background: 'transparent',
                            width: '100%'
                          }}
                        />
                      ) : (
                        item.content
                      )}
                    </div>
                  </Draggable>
                )
              ))}
            </div>

            {showAlert && (
              <div className="alert alert-success alert-dismissible fade show mt-3" role="alert">
                Your canvas has been exported as an image.
                <button type="button" className="btn-close" onClick={() => setShowAlert(false)}></button>
              </div>
            )}
          </div>
        </main>
      </div>
    </div>
  );
};

export default TextCanvas;
