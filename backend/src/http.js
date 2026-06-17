export class HttpError extends Error {
  constructor(status, message, details) {
    super(message);
    this.status = status;
    this.details = details;
  }
}

export function asyncHandler(handler) {
  return (req, res, next) => {
    Promise.resolve(handler(req, res, next)).catch(next);
  };
}

export function sendCreated(res, data) {
  return res.status(201).json({ data });
}

export function sendOk(res, data) {
  return res.json({ data });
}

export function notFound(message = 'Not found') {
  throw new HttpError(404, message);
}
