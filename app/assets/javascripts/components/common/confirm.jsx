import React from 'react';
import Modal from './modal.jsx';
import TextInput from './text_input.jsx';

const Confirm = React.createClass({
  displayName: 'Confirm',

  propTypes: {
    onConfirm: React.PropTypes.func.isRequired,
    onCancel: React.PropTypes.func.isRequired,
    message: React.PropTypes.string.isRequired,
    showInput: React.PropTypes.bool,
    joinDetails: React.PropTypes.string
  },

  getInitialState() {
    return { userInput: '' };
  },

  onConfirm() {
    this.props.onConfirm(this.state.userInput);
  },

  onCancel() {
    this.props.onCancel();
  },

  onChange(_valueKey, value) {
    this.setState({ userInput: value });
  },

  render() {
    let textInput;
    let joinDetails;
    if (this.props.showInput) {
      textInput = (
        <div className="join-user-input">
          <TextInput
            value={this.state.userInput}
            value_key="userInput"
            onChange={this.onChange}
            editable
          />
        </div>
      );
      joinDetails = (
        <div className="join-details">
          {this.props.joinDetails}
          <br />
          <br />
        </div>
      );
    }
    return (
      <Modal modalClass="confirm-modal-overlay">
        <div className="confirm-modal">
          {joinDetails}
          {this.props.message}
          {textInput}
          <br />
          <div className="pop_container pull-right">
            <button className="button ghost-button" onClick={this.onCancel}>{I18n.t('application.cancel')}</button>
            <button autoFocus className="button dark" onClick={this.onConfirm}>{I18n.t('application.confirm')}</button>
          </div>
        </div>
      </Modal>
    );
  }
});

export default Confirm;

